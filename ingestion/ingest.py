import os
import glob
import time
import requests
import uuid
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams, PointStruct

QDRANT_HOST = os.getenv("QDRANT_HOST", "http://localhost:6333")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "knowledge_base")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "nomic-embed-text") # Will need to be updated to match final model
VECTOR_DIM = int(os.getenv("VECTOR_DIM", "768")) # Will need to be updated to match final model
DOCS_DIR = os.getenv("DOCS_DIR", os.path.join(os.path.dirname(__file__), "documents"))

def wait_for_services(max_attempts: int = 30, delay: int = 2):
    # Ensure both Qdrant and Ollama are reachable before starting ingestion
    print("Verifying backend services readiness...")
    client = QdrantClient(url=QDRANT_HOST)
    
    # Check Qdrant
    for attempt in range(max_attempts):
        try:
            client.get_collections()
            print("Qdrant connection established.")
            break
        except Exception:
            if attempt == max_attempts - 1:
                raise RuntimeError(f"Could not connect to Qdrant at {QDRANT_HOST} after {max_attempts} attempts.")
            time.sleep(delay)

    # Check Ollama
    for attempt in range(max_attempts):
        try:
            res = requests.get(f"{OLLAMA_HOST}/", timeout=5)
            if res.status_code == 200:
                print("Ollama connection established.")
                return client
        except Exception:
            pass
        if attempt == max_attempts - 1:
            raise RuntimeError(f"Could not connect to Ollama at {OLLAMA_HOST} after {max_attempts} attempts.")
        time.sleep(delay)

    return client

def get_embedding(text: str, retries: int = 3) -> list:
    for attempt in range(retries):
        try:
            resp = requests.post(
                f"{OLLAMA_HOST}/api/embeddings",
                json={"model": EMBEDDING_MODEL, "prompt": text},
                timeout=45
            )
            resp.raise_for_status()
            return resp.json()["embedding"]
        except Exception as e:
            if attempt == retries - 1:
                raise RuntimeError(f"Failed to generate embedding: {e}")
            time.sleep(2 ** attempt)

def main():
    client = wait_for_services()

    # Idempotently create collection if it does not exist
    collections = [c.name for c in client.get_collections().collections]
    if COLLECTION_NAME not in collections:
        print(f"Creating collection '{COLLECTION_NAME}' (dim={VECTOR_DIM})...")
        client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(size=VECTOR_DIM, distance=Distance.COSINE)
        )
    else:
        print(f"Collection '{COLLECTION_NAME}' already initialized.")
    
    # Process text documents
    doc_paths = sorted(glob.glob(os.path.join(DOCS_DIR, "*.txt")))
    if not doc_paths:
        print(f"No documents found in {DOCS_DIR}.")
        return

    points = []
    chunk_size = 400
    chunk_overlap = 50

    for path in doc_paths:
        filename = os.path.basename(path)
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        chunks = []
        start = 0
        while start < len(content):
            end = min(start + chunk_size, len(content))
            chunks.append(content[start:end])
            if end == len(content):
                break
            start += chunk_size - chunk_overlap

        for idx, chunk in enumerate(chunks):
            # Deterministic UUID ensures reruns overwrite without creating duplicates
            point_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"{filename}_{idx}"))
            vec = get_embedding(chunk)

            points.append(PointStruct(
                id=point_id,
                vector=vec,
                payload={
                    "source": filename,
                    "chunk_index": idx,
                    "content": chunk
                }
            ))

    if points:
        client.upsert(collection_name=COLLECTION_NAME, points=points)
        print(f"Successfully processed {len(doc_paths)} documents ({len(points)} chunks) into '{COLLECTION_NAME}'.")

if __name__ == "__main__":
    main()