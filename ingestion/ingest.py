import os
from qdrant_client import QdrantClient

QDRANT_HOST = os.getenv("QDRANT_HOST", "http://localhost:6333")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "knowledge_base")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "nomic-embed-text")
VECTOR_DIM = int(os.getenv("VECTOR_DIM", "768"))
DOCS_DIR = os.getenv("DOCS_DIR", os.path.join(os.path.dirname(__file__), "documents"))

def main():
    print(f"Connecting to Qdrant at {QDRANT_HOST}...")
    client = QdrantClient(url=QDRANT_HOST)
    print("Qdrant client connection initialized.")

if __name__ == "__main__":
    main()