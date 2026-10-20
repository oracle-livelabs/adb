export function buildGraphPages(vertices, edges, rowLimit, batchVertex) {
  const batchId = batchVertex ? String(batchVertex.id) : null;
  const pageCapacity = Math.max(1, rowLimit - (batchVertex ? 1 : 0));
  const focusVertices = batchId
    ? vertices.filter((vertex) => String(vertex.id) !== batchId)
    : vertices;
  const pageCount = Math.max(1, Math.ceil(focusVertices.length / pageCapacity));
  const adjacency = new Map(vertices.map((vertex) => [String(vertex.id), []]));

  edges.forEach((edge) => {
    const source = String(edge.source);
    const target = String(edge.target);
    if (!adjacency.has(source) || !adjacency.has(target)) return;
    adjacency.get(source).push(target);
    adjacency.get(target).push(source);
  });

  const parents = new Map();
  const distances = new Map();
  if (batchId && adjacency.has(batchId)) {
    const queue = [batchId];
    distances.set(batchId, 0);
    while (queue.length) {
      const current = queue.shift();
      adjacency.get(current).forEach((neighbor) => {
        if (distances.has(neighbor)) return;
        distances.set(neighbor, distances.get(current) + 1);
        parents.set(neighbor, current);
        queue.push(neighbor);
      });
    }
  }

  const pageIndexByVertexId = new Map();
  const pages = Array.from({ length: pageCount }, (_, index) => {
    const start = index * pageCapacity;
    const pageFocusVertices = focusVertices.slice(start, start + pageCapacity);
    const visibleIds = new Set(batchId ? [batchId] : []);

    pageFocusVertices.forEach((vertex) => {
      let current = String(vertex.id);
      visibleIds.add(current);
      while (parents.has(current)) {
        current = parents.get(current);
        visibleIds.add(current);
      }
      if (!pageIndexByVertexId.has(String(vertex.id))) {
        pageIndexByVertexId.set(String(vertex.id), index);
      }
    });

    const pageVertices = vertices.filter((vertex) => visibleIds.has(String(vertex.id)));
    const pageEdges = edges.filter((edge) => (
      visibleIds.has(String(edge.source)) && visibleIds.has(String(edge.target))
    ));
    return { focusVertices: pageFocusVertices, vertices: pageVertices, edges: pageEdges };
  });

  if (batchId && !pageIndexByVertexId.has(batchId)) pageIndexByVertexId.set(batchId, 0);
  return { pages, pageCount, pageIndexByVertexId, distances };
}
