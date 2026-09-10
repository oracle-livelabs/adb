import { Fragment, useEffect, useMemo, useRef, useState } from 'react';
import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet';
import L from 'leaflet';
import GraphVisualization from './vendor/oracle-graph-visualization/runtime.js';
import {
  Activity,
  ArrowUpRight,
  Bot,
  Braces,
  Boxes,
  ChevronRight,
  CircleAlert,
  FileSearch,
  GitGraph,
  LogOut,
  MapPinned,
  MessageCircle,
  PackageSearch,
  Send,
  Search,
  ShieldCheck,
  Sparkles,
  Store,
  Table2,
  Trash2,
  Users,
  UserRound,
  Maximize2,
  ZoomIn,
  ZoomOut,
  X
} from 'lucide-react';

const personas = [
  { value: 'STORE_101_USER', label: 'Store associate', hint: 'Store 101 scope' },
  { value: 'REGION_NE_USER', label: 'Northeast manager', hint: 'Northeast region' },
  { value: 'RECALL_LEAD_USER', label: 'Recall response lead', hint: 'Company-wide scope' }
];

const starterQuestions = [
  'What is the current approved recall scope for batch B-482?',
  'Summarize affected stores and shipped units by region.',
  'Are all affected stores within the 25-kilometer response radius?',
  'Which supplier or sub-vendor sites supplied the highest-risk lots?',
  'What production, receipt, and installation timing should investigators review?',
  'Which complaint IDs best support the overheating or electrical-odor pattern?',
  'What is the first response action, and is customer contact authorized?',
  'Which spatial coverage should the field team know?',
  'Which response regions and centers should this role prioritize, and why?',
  'Which component lots and supplier sites are connected to this recall?',
  'Which complaint evidence supports the spatial and graph pattern visible to me?'
];

const storeIcon = L.divIcon({
  className: 'store-marker',
  html: '<span></span>',
  iconSize: [18, 18],
  iconAnchor: [9, 9]
});

function formatNumber(value) {
  return new Intl.NumberFormat('en-US').format(Number(value || 0));
}

function TechTags({ items }) {
  return <div className="tech-tags" aria-label={`Technology: ${items.join(', ')}`}>
    {items.map((item) => <span className={`tech-tag tech-${item.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`} key={item} title={item === 'DDS' ? 'Deep Data Security' : `${item} technology`}>{item}</span>)}
  </div>;
}

async function api(path, options) {
  const response = await fetch(path, {
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', ...(options?.headers || {}) },
    ...options
  });
  const payload = response.status === 204 ? null : await response.json();
  if (!response.ok) throw new Error(payload?.error || 'Request failed.');
  return payload;
}

function Login({ onLogin }) {
  const [username, setUsername] = useState(personas[0].value);
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const selected = personas.find((persona) => persona.value === username);

  async function submit(event) {
    event.preventDefault();
    setBusy(true);
    setError('');
    try {
      const result = await api('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ username, password })
      });
      onLogin(result.identity);
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="login-shell">
      <section className="login-visual">
        <div className="brand-mark"><span>O</span> Oracle AI Database <b>26ai</b></div>
        <div className="login-data-card">
          <div className="login-data-heading"><div><p className="eyebrow">Recall dataset</p><h2>One investigation, converged evidence</h2></div><TechTags items={['JSON', 'Spatial', 'Graph', 'Vector']} /></div>
          <div className="login-data-grid">
            <div><strong>921</strong><span>stored JSON docs</span></div>
            <div><strong>100</strong><span>products</span></div>
            <div><strong>120</strong><span>components</span></div>
            <div><strong>300</strong><span>component batches</span></div>
            <div><strong>300</strong><span>complaints</span></div>
            <div><strong>25</strong><span>HeatPro parts</span></div>
          </div>
          <p className="login-data-note">The lead recall scope follows B-482 through stores, customers, component lots, sub-vendors, locations, and complaint evidence.</p>
        </div>
        <div className="login-visual-copy">
          <p className="eyebrow">Product recall operations</p>
          <h1>Make every recall decision traceable.</h1>
          <p>Explore the same recall evidence through a role-aware React and Node application.</p>
        </div>
        <div className="visual-network" aria-hidden="true">
          <span className="network-line line-one" />
          <span className="network-line line-two" />
          <span className="network-line line-three" />
          <span className="network-node node-one"><PackageSearch size={18} /></span>
          <span className="network-node node-two"><MapPinned size={18} /></span>
          <span className="network-node node-three"><Bot size={18} /></span>
          <span className="network-node node-four"><ShieldCheck size={18} /></span>
        </div>
        <div className="visual-footnote"><ShieldCheck size={15} /> Database-enforced role scope</div>
      </section>

      <section className="login-panel">
        <div className="mobile-brand brand-mark"><span>O</span> Oracle AI Database <b>26ai</b></div>
        <div className="login-card">
          <div className="login-icon"><ShieldCheck size={22} /></div>
          <p className="eyebrow">Secure workspace</p>
          <TechTags items={['DDS']} />
          <h2>Sign in to the command center</h2>
          <p className="muted">Your database identity controls the evidence and agent answers you can see.</p>
          <form onSubmit={submit}>
            <label htmlFor="persona">Recall persona</label>
            <select id="persona" value={username} onChange={(event) => setUsername(event.target.value)}>
              {personas.map((persona) => <option key={persona.value} value={persona.value}>{persona.label} · {persona.hint}</option>)}
            </select>
            <label htmlFor="password">Lab password</label>
            <input id="password" type="password" value={password} onChange={(event) => setPassword(event.target.value)} placeholder="Enter the shared Lab 7 password" autoComplete="current-password" />
            {error && <div className="error-message"><CircleAlert size={16} /> {error}</div>}
            <button className="primary-button full-width" type="submit" disabled={busy}>
              {busy ? 'Opening secure session...' : 'Open command center'} <ArrowUpRight size={17} />
            </button>
          </form>
          <div className="login-note"><Activity size={15} /><span>{selected.label} access is established by the database session, not a browser-only role toggle.</span></div>
          <div className="persona-overview">
            <div className="persona-overview-heading"><span>Deep Data Security personas</span><small>Agent acts for the signed-in user</small></div>
            <div className="persona-row"><Store size={15} /><div><b>Store associate</b><span>Store 101 · 1 store · 5 customers</span></div></div>
            <div className="persona-row"><MapPinned size={15} /><div><b>Northeast manager</b><span>Northeast · 24 stores · 120 customers</span></div></div>
            <div className="persona-row"><ShieldCheck size={15} /><div><b>Recall response lead</b><span>Company-wide · 120 stores · 600 customers</span></div></div>
            <p className="persona-overview-note"><Bot size={13} /> The same Select AI Agent receives only the JSON, Vector, Spatial, and Graph evidence authorized for this database identity.</p>
          </div>
        </div>
        <p className="login-footer">Hands-on Lab 8 · Role-aware recall operations</p>
      </section>
    </main>
  );
}

function StatCard({ icon: Icon, label, value, detail, tone }) {
  return (
    <article className={`stat-card ${tone}`}>
      <div className="stat-icon"><Icon size={18} /></div>
      <div>
        <p>{label}</p>
        <strong>{value}</strong>
        <span>{detail}</span>
        <TechTags items={tone === 'teal' ? ['Spatial'] : tone === 'orange' ? ['JSON'] : tone === 'blue' ? ['DDS'] : ['Vector']} />
      </div>
    </article>
  );
}

function MapPanel({ stores }) {
  const features = stores?.features || [];
  return (
    <section className="panel map-panel" id="map">
      <div className="panel-header">
        <div>
          <p className="eyebrow">Spatial impact</p>
          <h2>Authorized store footprint</h2>
          <TechTags items={['Spatial', 'JSON', 'DDS']} />
        </div>
        <span className="panel-count"><MapPinned size={14} /> {features.length} locations</span>
      </div>
      <div className="map-wrap">
        <MapContainer center={[39, -98]} zoom={4} minZoom={3} maxZoom={9} scrollWheelZoom className="recall-map">
          <TileLayer attribution='&copy; OpenStreetMap contributors' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
          {features.map((feature) => {
            const [longitude, latitude] = feature.geometry.coordinates;
            const properties = feature.properties;
            return (
              <Marker key={properties.storeId} position={[latitude, longitude]} icon={storeIcon}>
                <Popup>
                  <strong>{properties.storeCode} · {properties.storeName}</strong><br />
                  {properties.regionCode} · {formatNumber(properties.unitsSent)} units
                </Popup>
              </Marker>
            );
          })}
        </MapContainer>
        <div className="map-legend"><span className="legend-dot" /> Authorized location</div>
      </div>
    </section>
  );
}

function RegionBars({ stores }) {
  const regions = useMemo(() => {
    const totals = (stores?.features || []).reduce((result, feature) => {
      const region = feature.properties.regionCode;
      result[region] = (result[region] || 0) + 1;
      return result;
    }, {});
    const rows = Object.entries(totals).sort((a, b) => b[1] - a[1]);
    const maximum = Math.max(...rows.map(([, count]) => count), 1);
    return rows.map(([region, count]) => ({ region, count, width: `${Math.max(10, (count / maximum) * 100)}%` }));
  }, [stores]);

  return (
    <section className="panel region-panel">
      <div className="panel-header compact"><div><p className="eyebrow">Coverage</p><h2>Stores by region</h2><TechTags items={['Spatial', 'DDS']} /></div><Activity size={17} className="panel-action" /></div>
      <div className="region-list">
        {regions.map((row) => <div className="region-row" key={row.region}><div><span>{row.region}</span><b>{row.count}</b></div><div className="bar-track"><span style={{ width: row.width }} /></div></div>)}
      </div>
    </section>
  );
}

function ProductPanel({ product }) {
  const components = product?.components || [];
  const [productView, setProductView] = useState('json');
  const relationalFields = [
    ['PRODUCT_NAME', product?.product],
    ['SKU', product?.sku],
    ['CATEGORY', product?.category],
    ['BATCH_ID', product?.batchId],
    ['RECALL_STATUS', product?.recallStatus],
    ['ISSUE_CODE', product?.issueCode],
    ['MANUFACTURED_ON', product?.manufacturedOn],
    ['ISSUE_SUMMARY', product?.issueSummary]
  ];
  return (
    <section className="panel product-panel" id="evidence">
      <div className="panel-header"><div><p className="eyebrow">Product record</p><h2>{product?.product || 'HeatPro Countertop Cooker'}</h2><TechTags items={['JSON']} /></div><span className="status-pill"><span /> {product?.recallStatus || 'INVESTIGATING'}</span></div>
      <div className="product-meta"><span><b>SKU</b>{product?.sku}</span><span><b>Category</b>{product?.category}</span><span><b>Batch</b>{product?.batchId}</span><span><b>Issue</b>{product?.issueCode}</span></div>
      <div className="product-view-switch" role="tablist" aria-label="Product data view"><button type="button" className={productView === 'json' ? 'active' : ''} role="tab" aria-selected={productView === 'json'} onClick={() => setProductView('json')}><Braces size={14} /> JSON document</button><button type="button" className={productView === 'relational' ? 'active' : ''} role="tab" aria-selected={productView === 'relational'} onClick={() => setProductView('relational')}><Table2 size={14} /> Relational view</button></div>
      {productView === 'json' ? <div className="product-json-view"><div className="product-view-caption"><Braces size={14} /><span>Native JSON payload returned by the product context API</span></div><pre>{JSON.stringify(product || {}, null, 2)}</pre></div> : <div className="product-relational-view"><div className="product-view-caption"><Table2 size={14} /><span>Relational projection of the same JSON document</span></div><div className="relational-field-list">{relationalFields.map(([field, value]) => <div key={field}><b>{field}</b><span>{String(value ?? 'null')}</span></div>)}</div><div className="relational-components"><b>PRODUCT_COMPONENTS</b><div className="relational-component-table"><span>COMPONENT_CODE</span><span>COMPONENT_NAME</span><span>CRITICALITY</span>{components.map((component) => <Fragment key={component.code}><span>{component.code}</span><span>{component.name}</span><span>{component.criticality}</span></Fragment>)}</div></div></div>}
      <div className="issue-callout"><CircleAlert size={17} /><div><b>Thermal-risk investigation</b><p>{product?.issueSummary}</p></div></div>
      <div className="component-section"><div className="section-label"><Boxes size={15} /> Product components</div><div className="component-list">{components.slice(0, 8).map((component) => <span key={component.code} title={`${component.name} · ${component.criticality}`}>{component.code}</span>)}</div><p className="component-footnote">{components.length} traceable components in the product definition</p></div>
    </section>
  );
}

function ComplaintPanel({ complaints, batchId }) {
  const [query, setQuery] = useState('');
  const [rows, setRows] = useState(complaints || []);
  const [searching, setSearching] = useState(false);
  const [searched, setSearched] = useState(false);

  useEffect(() => {
    setRows(complaints || []);
    setSearched(false);
  }, [complaints]);

  async function searchEvidence(event) {
    event.preventDefault();
    const clean = query.trim();
    if (!clean || searching) return;
    setSearching(true);
    try {
      const payload = await api('/api/vector-search', {
        method: 'POST',
        body: JSON.stringify({ batchId, query: clean })
      });
      setRows(payload.results || []);
      setSearched(true);
    } catch (error) {
      setRows([{ complaintId: 'ERR', text: error.message, distance: null }]);
      setSearched(true);
    } finally {
      setSearching(false);
    }
  }

  return (
    <section className="panel complaint-panel">
      <div className="panel-header compact"><div><p className="eyebrow">Vector evidence</p><h2>Priority complaints</h2><TechTags items={['Vector', 'JSON', 'DDS']} /></div><FileSearch size={17} className="panel-action" /></div>
      <form className="vector-search" onSubmit={searchEvidence}>
        <Search size={15} />
        <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search symptoms or complaint evidence" aria-label="Search symptoms or complaint evidence" />
        <button type="submit" disabled={!query.trim() || searching} title="Search authorized complaint vectors" aria-label="Search authorized complaint vectors"><Search size={15} /></button>
      </form>
      <p className="vector-search-note">{searched ? 'Showing the closest matches from your authorized complaint vectors.' : 'Showing the default thermal-risk matches. Search to run a new vector query.'}</p>
      <div className="complaint-list">
        {rows.length ? rows.map((complaint) => <div className={`complaint-row${complaint.complaintId === 'ERR' ? ' error-row' : ''}`} key={`${complaint.complaintId}-${complaint.distance}`}><div className="complaint-id">{complaint.complaintId}</div><div className="complaint-copy"><p>{complaint.text}</p><span>{complaint.distance === null ? 'Search unavailable' : `Cosine distance ${complaint.distance}`}</span></div><ChevronRight size={15} /></div>) : <div className="evidence-empty"><FileSearch size={18} /><span>No authorized complaint vectors matched this recall scope.</span></div>}
      </div>
    </section>
  );
}

const graphLayoutOptions = [
  { value: 'top-down', label: 'Top down' },
  { value: 'left-right', label: 'Left to right' },
  { value: 'force', label: 'Force' },
  { value: 'radial', label: 'Radial' },
  { value: 'circle', label: 'Circle' },
  { value: 'grid', label: 'Grid' }
];

const graphFilterOptions = [
  { value: 'all', label: 'Show all', labels: null },
  { value: 'component', label: 'Components', labels: ['component'] },
  { value: 'component_batch', label: 'Sub-components', labels: ['component_batch'] },
  { value: 'supplier', label: 'Suppliers', labels: ['supplier'] },
  { value: 'supplier_site', label: 'Supplier sites', labels: ['supplier_site'] },
  { value: 'store', label: 'Stores', labels: ['store'] },
  { value: 'customer', label: 'Customers', labels: ['customer'] }
];

function RecallGraphFallback({ vertices, edges, layoutType, onLayoutTypeChange }) {
  const [scale, setScale] = useState(0.72);
  const [offset, setOffset] = useState({ x: 0, y: 0 });
  const [maxHops, setMaxHops] = useState(1);
  const [filterType, setFilterType] = useState('all');
  const [focusedId, setFocusedId] = useState(null);
  const [selectedEdge, setSelectedEdge] = useState(null);
  const [selectedNode, setSelectedNode] = useState(null);
  const [hoveredEdgeId, setHoveredEdgeId] = useState(null);
  const [searchText, setSearchText] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchMatchIds, setSearchMatchIds] = useState(new Set());
  const [searchTargetId, setSearchTargetId] = useState(null);
  const svgRef = useRef(null);
  const dragRef = useRef(null);
  const panRef = useRef(null);
  const width = 1500;
  const colorByLabel = { batch: '#b85d3b', component_batch: '#327c9a', component: '#3d8d72', supplier_site: '#8d6aa9', supplier: '#c18b2b', store: '#26828c', customer: '#ba6f8f' };
  const graphTraversal = useMemo(() => {
    const batch = vertices.find((vertex) => vertex.labels?.includes('batch'));
    const distances = new Map();
    const parents = new Map();
    const adjacency = new Map(vertices.map((vertex) => [String(vertex.id), []]));
    if (!batch) return { distances, parents, adjacency };
    edges.forEach((edge) => {
      const source = String(edge.source);
      const target = String(edge.target);
      if (adjacency.has(source) && adjacency.has(target)) {
        adjacency.get(source).push(target);
        adjacency.get(target).push(source);
      }
    });
    const queue = [String(batch.id)];
    distances.set(String(batch.id), 0);
    while (queue.length) {
      const current = queue.shift();
      const distance = distances.get(current);
      adjacency.get(current)?.forEach((neighbor) => {
        if (!distances.has(neighbor)) {
          distances.set(neighbor, distance + 1);
          parents.set(neighbor, current);
          queue.push(neighbor);
        }
      });
    }
    return { distances, parents, adjacency, batchId: String(batch.id) };
  }, [vertices, edges]);
  const hopDistances = graphTraversal.distances;
  const displayVertices = useMemo(
    () => {
      const withinDistance = vertices.filter((vertex) => (hopDistances.get(String(vertex.id)) ?? Number.POSITIVE_INFINITY) <= maxHops);
      if (filterType === 'all') return withinDistance;
      const filter = graphFilterOptions.find((option) => option.value === filterType);
      const visibleIds = new Set(
        withinDistance
          .filter((vertex) => filter?.labels?.includes(vertex.labels?.[0]))
          .map((vertex) => String(vertex.id))
      );
      visibleIds.add(graphTraversal.batchId);
      [...visibleIds].forEach((id) => {
        let current = id;
        while (graphTraversal.parents.has(current)) {
          current = graphTraversal.parents.get(current);
          visibleIds.add(current);
        }
      });
      return withinDistance.filter((vertex) => visibleIds.has(String(vertex.id)));
    },
    [vertices, hopDistances, maxHops, filterType, graphTraversal]
  );
  const displayVertexById = useMemo(() => new Map(displayVertices.map((vertex) => [String(vertex.id), vertex])), [displayVertices]);
  const displayEdges = useMemo(
    () => edges.filter((edge) => displayVertexById.has(String(edge.source)) && displayVertexById.has(String(edge.target))),
    [edges, displayVertexById]
  );
  const layout = useMemo(() => {
    const stageFor = (vertex) => {
      const label = vertex.labels?.[0];
      if (label === 'batch') return 0;
      if (label === 'component_batch' || label === 'component') return 1;
      if (label === 'supplier_site' || label === 'supplier') return 2;
      if (label === 'store') return 3;
      return 4;
    };
    const stages = [0, 1, 2, 3, 4].map((stage) => displayVertices.filter((vertex) => stageFor(vertex) === stage));
    const positions = new Map();
    let height = layoutType === 'force'
      ? Math.max(1100, Math.min(1800, 760 + Math.ceil(displayVertices.length / 20) * 140))
      : 820;

    if (layoutType === 'top-down' || layoutType === 'left-right') {
      let cursor = 70;
      stages.forEach((stageVertices) => {
        if (layoutType === 'top-down') {
          const columns = Math.max(1, Math.min(24, Math.ceil(Math.sqrt(stageVertices.length * 1.4))));
          const columnGap = columns === 1 ? 0 : (width - 140) / (columns - 1);
          const rows = Math.ceil(stageVertices.length / columns);
          const rowGap = 62;
          stageVertices.forEach((vertex, index) => {
            const column = index % columns;
            const row = Math.floor(index / columns);
            positions.set(String(vertex.id), { x: columns === 1 ? width / 2 : 70 + column * columnGap, y: cursor + row * rowGap });
          });
          cursor += Math.max(150, rows * rowGap + 100);
          height = Math.max(height, cursor);
        } else {
          const rows = Math.max(1, Math.min(24, Math.ceil(Math.sqrt(stageVertices.length * 1.4))));
          const columns = Math.ceil(stageVertices.length / rows);
          stageVertices.forEach((vertex, index) => {
            const column = Math.floor(index / rows);
            const row = index % rows;
            positions.set(String(vertex.id), { x: cursor + column * 62, y: rows === 1 ? height / 2 : 70 + row * ((height - 140) / (rows - 1)) });
          });
          cursor += Math.max(150, columns * 62 + 100);
        }
      });
      if (layoutType === 'left-right') height = Math.max(760, height);
    } else if (layoutType === 'grid') {
      const columns = Math.max(1, Math.min(24, Math.ceil(Math.sqrt(displayVertices.length * 1.4))));
      const columnGap = columns === 1 ? 0 : (width - 140) / (columns - 1);
      const rowGap = 62;
      displayVertices.forEach((vertex, index) => {
        const column = index % columns;
        const row = Math.floor(index / columns);
        positions.set(String(vertex.id), { x: columns === 1 ? width / 2 : 70 + column * columnGap, y: 70 + row * rowGap });
      });
      height = Math.max(820, Math.ceil(displayVertices.length / columns) * rowGap + 180);
    } else if (layoutType === 'circle' || layoutType === 'radial') {
      const center = { x: width / 2, y: height / 2 };
      if (layoutType === 'circle') {
          const radius = Math.min(width, height) * 0.42;
        displayVertices.forEach((vertex, index) => {
          const angle = (index / Math.max(1, displayVertices.length)) * Math.PI * 2 - Math.PI / 2;
          positions.set(String(vertex.id), { x: center.x + Math.cos(angle) * radius, y: center.y + Math.sin(angle) * radius });
        });
      } else {
        stages.forEach((stageVertices, stage) => {
          if (stage === 0 && stageVertices.length) positions.set(String(stageVertices[0].id), center);
          const ring = stage === 0 ? 0 : 140 + stage * 110;
          stageVertices.filter((vertex) => stage !== 0 || !positions.has(String(vertex.id))).forEach((vertex, index, ringVertices) => {
            const angle = (index / Math.max(1, ringVertices.length)) * Math.PI * 2 - Math.PI / 2;
            positions.set(String(vertex.id), { x: center.x + Math.cos(angle) * ring, y: center.y + Math.sin(angle) * ring });
          });
        });
        height = 980;
      }
    } else {
      const forceNodes = displayVertices.map((vertex, index) => {
        const angle = (index / Math.max(1, displayVertices.length)) * Math.PI * 2;
        const radius = 260 + (index % 7) * 100;
        return { id: String(vertex.id), x: width / 2 + Math.cos(angle) * radius, y: height / 2 + Math.sin(angle) * radius, vx: 0, vy: 0 };
      });
      const forceLinks = displayEdges.map((edge) => [forceNodes.find((node) => node.id === edge.source), forceNodes.find((node) => node.id === edge.target)]).filter(([source, target]) => source && target);
      for (let iteration = 0; iteration < 140; iteration += 1) {
        for (let i = 0; i < forceNodes.length; i += 1) {
          for (let j = i + 1; j < forceNodes.length; j += 1) {
            const first = forceNodes[i];
            const second = forceNodes[j];
            const dx = second.x - first.x;
            const dy = second.y - first.y;
            const distance = Math.max(28, Math.sqrt(dx * dx + dy * dy));
            const force = 9800 / (distance * distance);
            first.vx -= (dx / distance) * force;
            first.vy -= (dy / distance) * force;
            second.vx += (dx / distance) * force;
            second.vy += (dy / distance) * force;
          }
        }
        forceLinks.forEach(([source, target]) => {
          const dx = target.x - source.x;
          const dy = target.y - source.y;
          const distance = Math.max(1, Math.sqrt(dx * dx + dy * dy));
          const force = ((distance - 300) / distance) * 0.022;
          source.vx += dx * force;
          source.vy += dy * force;
          target.vx -= dx * force;
          target.vy -= dy * force;
        });
        forceNodes.forEach((node) => {
          node.vx = (node.vx + (width / 2 - node.x) * 0.00045) * 0.88;
          node.vy = (node.vy + (height / 2 - node.y) * 0.00045) * 0.88;
          node.x = Math.max(60, Math.min(width - 60, node.x + node.vx));
          node.y = Math.max(60, Math.min(height - 60, node.y + node.vy));
        });
      }
      forceNodes.forEach((node) => positions.set(node.id, { x: node.x, y: node.y }));
    }

    const points = [...positions.values()];
    const minX = Math.min(...points.map((point) => point.x), width / 2);
    const maxX = Math.max(...points.map((point) => point.x), width / 2);
    const minY = Math.min(...points.map((point) => point.y), height / 2);
    const maxY = Math.max(...points.map((point) => point.y), height / 2);
    return { nodes: positions, height, center: { x: width / 2 - (minX + maxX) / 2, y: height / 2 - (minY + maxY) / 2 } };
  }, [displayVertices, displayEdges, layoutType]);
  const [nodes, setNodes] = useState(new Map());
  useEffect(() => {
    setNodes(new Map(layout.nodes));
    setOffset(layout.center);
    setSelectedEdge(null);
  }, [layout]);
  const nodeById = nodes;
  const focusedPath = useMemo(() => {
    const nodeIds = new Set();
    const edgePairs = new Set();
    if (!focusedId || !hopDistances.has(focusedId)) return { nodeIds, edgePairs };
    const queue = [focusedId];
    nodeIds.add(focusedId);
    while (queue.length) {
      const current = queue.shift();
      const currentDistance = hopDistances.get(current);
      if (!currentDistance) continue;
      graphTraversal.adjacency.get(current)?.forEach((neighbor) => {
        if (hopDistances.get(neighbor) !== currentDistance - 1) return;
        nodeIds.add(neighbor);
        edgePairs.add([current, neighbor].sort().join('|'));
        if (!queue.includes(neighbor)) queue.push(neighbor);
      });
    }
    return { nodeIds, edgePairs };
  }, [focusedId, hopDistances, graphTraversal.adjacency]);
  const focusedPathEdgeIds = useMemo(() => new Set(
    displayEdges
      .filter((edge) => focusedPath.edgePairs.has([String(edge.source), String(edge.target)].sort().join('|')))
      .map((edge) => edge.id)
  ), [displayEdges, focusedPath.edgePairs]);
  useEffect(() => {
    if (!searchTargetId) return;
    const node = nodeById.get(searchTargetId);
    if (!node) return;
    setSelectedNode(displayVertexById.get(searchTargetId) || null);
    setFocusedId(searchTargetId);
    setOffset({ x: width / (2 * scale) - node.x, y: layout.height / (2 * scale) - node.y });
    setSearchTargetId(null);
  }, [nodeById, searchTargetId, layout.height, scale]);
  const zoom = (delta) => setScale((value) => Math.min(2.2, Math.max(0.35, Number((value + delta).toFixed(2)))));
  const reset = () => {
    setScale(0.72);
    setOffset(layout.center);
    setFocusedId(null);
    setSelectedEdge(null);
    setSelectedNode(null);
    setMaxHops(1);
    setFilterType('all');
    setSearchText('');
    setSearchQuery('');
    setSearchMatchIds(new Set());
    setSearchTargetId(null);
  };
  const graphPoint = (event) => {
    const rect = svgRef.current.getBoundingClientRect();
    return {
      x: ((event.clientX - rect.left) / rect.width) * width / scale - offset.x,
      y: ((event.clientY - rect.top) / rect.height) * layout.height / scale - offset.y
    };
  };
  const focusNode = (id) => {
    const node = nodeById.get(id);
    if (!node) return;
    setSelectedNode(displayVertexById.get(id) || null);
    setSelectedEdge(null);
    setSearchText('');
    setSearchQuery('');
    setSearchMatchIds(new Set());
    setFocusedId(id);
    setOffset({ x: width / (2 * scale) - node.x, y: layout.height / (2 * scale) - node.y });
  };
  const clearSearch = () => {
    setSearchText('');
    setSearchQuery('');
    setSearchMatchIds(new Set());
    setSearchTargetId(null);
    setFocusedId(null);
  };
  const runSearch = (event) => {
    event.preventDefault();
    const query = searchText.trim().toLowerCase();
    if (!query) {
      clearSearch();
      return;
    }
    const searchableText = (vertex) => `${vertex.id} ${(vertex.labels || []).join(' ')} ${Object.values(vertex.properties || {}).map((value) => typeof value === 'object' ? JSON.stringify(value) : value).join(' ')}`.toLowerCase();
    const matches = displayVertices.filter((vertex) => searchableText(vertex).includes(query));
    setSearchQuery(query);
    setSearchMatchIds(new Set(matches.map((vertex) => String(vertex.id))));
    setFocusedId(null);
    setSelectedEdge(null);
    setSearchTargetId(matches.length ? String(matches[0].id) : null);
  };
  const selectEdge = (edge) => {
    setSelectedNode(null);
    setSelectedEdge(edge);
  };
  const startDrag = (event, id) => {
    event.stopPropagation();
    const node = nodeById.get(id);
    if (!node) return;
    const point = graphPoint(event);
    dragRef.current = { id, dx: point.x - node.x, dy: point.y - node.y, startX: event.clientX, startY: event.clientY, moved: false };
    event.currentTarget.setPointerCapture?.(event.pointerId);
  };
  const startPan = (event) => {
    if (event.button !== 0) return;
    event.preventDefault();
    panRef.current = { clientX: event.clientX, clientY: event.clientY, offset };
    svgRef.current.setPointerCapture?.(event.pointerId);
  };
  const moveDrag = (event) => {
    if (panRef.current) {
      const rect = svgRef.current.getBoundingClientRect();
      const deltaX = ((event.clientX - panRef.current.clientX) / rect.width) * width / scale;
      const deltaY = ((event.clientY - panRef.current.clientY) / rect.height) * layout.height / scale;
      setOffset({ x: panRef.current.offset.x + deltaX, y: panRef.current.offset.y + deltaY });
      return;
    }
    if (!dragRef.current) return;
    if (Math.hypot(event.clientX - dragRef.current.startX, event.clientY - dragRef.current.startY) > 5) dragRef.current.moved = true;
    const point = graphPoint(event);
    const { id, dx, dy } = dragRef.current;
    setNodes((current) => new Map([...current, [id, { x: point.x - dx, y: point.y - dy }]]));
  };
  const endDrag = () => { dragRef.current = null; panRef.current = null; };
  const finishNodeInteraction = (event, id) => {
    event.stopPropagation();
    const moved = dragRef.current?.id === id && dragRef.current.moved;
    endDrag();
    if (!moved) focusNode(id);
  };
  const connectedToFocus = (id) => {
    if (searchMatchIds.size) return searchMatchIds.has(id) || displayEdges.some((edge) => (searchMatchIds.has(edge.source) && edge.target === id) || (searchMatchIds.has(edge.target) && edge.source === id));
    return !focusedId || focusedPath.nodeIds.has(id);
  };
  const edgeConnectedToFocus = (edge) => {
    if (searchMatchIds.size) return searchMatchIds.has(edge.source) || searchMatchIds.has(edge.target);
    return !focusedId || focusedPathEdgeIds.has(edge.id);
  };
  const edgeCaption = (edge) => `${edge.label || edge.type || 'relationship'}${edge.count > 1 ? ` x${edge.count}` : ''}`;
  const legend = [
    ['batch', 'Recall batch'],
    ['component_batch', 'Component lot'],
    ['component', 'Component'],
    ['supplier_site', 'Supplier site'],
    ['supplier', 'Supplier'],
    ['store', 'Authorized store'],
    ['customer', 'Authorized customer']
  ];

  return <div className="graph-fallback-wrap">
    <form className="graph-search" role="search" onSubmit={runSearch}>
      <Search size={14} aria-hidden="true" />
      <input value={searchText} onChange={(event) => setSearchText(event.target.value)} placeholder="Search nodes, IDs, suppliers..." aria-label="Search property graph" />
      {(searchText || searchQuery) && <button type="button" onClick={clearSearch} title="Clear graph search" aria-label="Clear graph search"><X size={13} /></button>}
      <button type="submit" title="Search property graph" aria-label="Search property graph"><Search size={13} /></button>
    </form>
    <label className="graph-layout-picker" title="Change graph layout">
      <span>Layout</span>
      <select value={layoutType} onChange={(event) => onLayoutTypeChange(event.target.value)} aria-label="Change graph layout">
        {graphLayoutOptions.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}
      </select>
    </label>
    <label className="graph-distance-picker" title="Show nodes within this many relationships of the recall batch">
      <span>Distance</span>
      <select value={maxHops} onChange={(event) => { setMaxHops(Number(event.target.value)); setFocusedId(null); setSelectedNode(null); setSelectedEdge(null); }} aria-label="Graph distance in hops">
        {[1, 2, 3, 4, 5].map((hops) => <option key={hops} value={hops}>{hops} hop{hops === 1 ? '' : 's'}</option>)}
      </select>
    </label>
    <label className="graph-filter-picker" title="Filter the graph by vertex type">
      <span>Filter</span>
      <select value={filterType} onChange={(event) => { setFilterType(event.target.value); setFocusedId(null); setSelectedNode(null); setSelectedEdge(null); }} aria-label="Filter graph by vertex type">
        {graphFilterOptions.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}
      </select>
    </label>
    <div className="graph-controls" aria-label="Graph controls">
      <button type="button" onClick={() => zoom(0.12)} title="Zoom in" aria-label="Zoom in"><ZoomIn size={16} /></button>
      <button type="button" onClick={() => zoom(-0.12)} title="Zoom out" aria-label="Zoom out"><ZoomOut size={16} /></button>
      <button type="button" onClick={reset} title="Center graph" aria-label="Center graph"><Maximize2 size={16} /></button>
      <span>{Math.round(scale * 100)}%</span>
    </div>
    {selectedNode && <aside className="graph-node-detail" role="dialog" aria-label="Selected graph node data"><div className="graph-node-detail-title"><span>Node data</span><button type="button" onClick={() => setSelectedNode(null)} title="Close node data" aria-label="Close node data"><X size={13} /></button></div><strong>{selectedNode.properties?.name || selectedNode.id}</strong><div className="graph-node-detail-meta"><span>{selectedNode.labels?.join(' · ') || 'vertex'}</span><span>ID {selectedNode.id}</span></div><pre>{JSON.stringify(selectedNode, null, 2)}</pre></aside>}
    <div className="graph-legend" aria-label="Graph legend">
      <div className="graph-legend-heading"><GitGraph size={13} /> <strong>Graph legend</strong></div>
      <div className="graph-legend-items">
        {legend.map(([label, title]) => <span key={label}>{label === 'customer' ? <UserRound className="graph-person-legend" size={13} strokeWidth={2.4} style={{ color: colorByLabel[label] }} /> : <i style={{ background: colorByLabel[label] }} />} {title}</span>)}
        <span className="graph-legend-relationship"><i /> Relationship</span>
      </div>
    </div>
    <svg ref={svgRef} className="graph-fallback-svg" viewBox={`0 0 ${width} ${layout.height}`} role="img" aria-label="Role-aware recall property graph" onPointerDown={startPan} onPointerMove={moveDrag} onPointerUp={endDrag} onPointerLeave={endDrag}>
      <defs><marker id="recall-graph-arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#8b9aa0" /></marker></defs>
      <g transform={`translate(${offset.x} ${offset.y}) scale(${scale})`}>
        {displayEdges.map((edge) => {
          const source = nodeById.get(edge.source);
          const target = nodeById.get(edge.target);
          if (!source || !target) return null;
          const active = hoveredEdgeId === edge.id || selectedEdge?.id === edge.id;
          const visible = edgeConnectedToFocus(edge);
          const caption = edgeCaption(edge);
          const midpointX = (source.x + target.x) / 2;
          const midpointY = (source.y + target.y) / 2;
          const pathHighlighted = focusedId && focusedPathEdgeIds.has(edge.id);
          return <g key={edge.id} className={`graph-fallback-edge${pathHighlighted ? ' path-highlight' : ''}`} opacity={visible ? 1 : 0.1} onPointerEnter={() => setHoveredEdgeId(edge.id)} onPointerLeave={() => setHoveredEdgeId(null)} onPointerDown={(event) => event.stopPropagation()} onClick={() => selectEdge(edge)}>
            <line x1={source.x} y1={source.y} x2={target.x} y2={target.y} stroke={pathHighlighted ? '#167f78' : (active ? '#31545c' : '#8b9aa0')} strokeWidth={pathHighlighted || active ? '3' : '1.8'} markerEnd="url(#recall-graph-arrow)" />
            <g className="graph-edge-label" opacity={visible ? 1 : 0.3} transform={`translate(${midpointX} ${midpointY})`}><rect x={-(caption.length * 3.1 + 10)} y="-11" width={caption.length * 6.2 + 20} height="20" rx="5" /><text textAnchor="middle" y="4">{caption}</text></g>
            <title>{caption}</title>
          </g>;
        })}
        {displayVertices.map((vertex) => {
          const position = nodeById.get(String(vertex.id));
          if (!position) return null;
          const label = vertex.labels?.[0] || 'other';
          const name = vertex.properties?.name || vertex.id;
          const focused = connectedToFocus(String(vertex.id));
          const nodeCaption = `${label}: ${name}`;
          const pathHighlighted = focusedId && focusedPath.nodeIds.has(String(vertex.id));
          return <g key={vertex.id} transform={`translate(${position.x} ${position.y})`} className={`graph-fallback-node${pathHighlighted ? ' path-highlight' : ''}${focusedId === String(vertex.id) ? ' selected' : ''}`} aria-label={`${label}: ${name}`} opacity={focused ? 1 : 0.18} onPointerDown={(event) => startDrag(event, String(vertex.id))} onPointerUp={(event) => finishNodeInteraction(event, String(vertex.id))} onPointerCancel={(event) => { event.stopPropagation(); endDrag(); }}>
            <circle r={label === 'customer' ? 13 : 10} fill={colorByLabel[label] || '#5f777d'} stroke="#fff" strokeWidth="2" />{label === 'customer' && <UserRound x="-9" y="-9" width="18" height="18" color="#fff" strokeWidth={2.2} pointerEvents="none" />}
            <text className="graph-node-label" x="15" y="4">{nodeCaption.slice(0, 38)}</text>
            <title>{`${label}: ${name}`}</title>
          </g>;
        })}
      </g>
    </svg>
  </div>;
}

function GraphPanel({ graph }) {
  const targetRef = useRef(null);
  const [renderError, setRenderError] = useState('');
  const [layoutType, setLayoutType] = useState('force');
  const showFallback = true;
  const vertices = graph?.vertices || [];
  const edges = graph?.edges || [];
  const oracleLayout = layoutType === 'top-down'
    ? { type: 'hierarchical', rankDirection: 'TB', ranker: 'network-simplex', vertexSeparation: 58, edgeSeparation: 24, rankSeparation: 112 }
    : layoutType === 'left-right'
      ? { type: 'hierarchical', rankDirection: 'LR', ranker: 'network-simplex', vertexSeparation: 58, edgeSeparation: 24, rankSeparation: 112 }
      : layoutType === 'force'
        ? { type: 'force', spacing: 280, alphaDecay: 0.028, velocityDecay: 0.34, edgeDistance: 300, vertexCharge: -720, clusterEnabled: false }
        : { type: layoutType, spacing: 90 };

  useEffect(() => {
    if (!targetRef.current || !graph || !vertices.length) return undefined;
    setRenderError('');
    let visualization;
    try {
      visualization = new GraphVisualization({
        target: targetRef.current,
        props: {
          data: graph,
          styles: {
            vertex: {
              label: '${properties.name}',
              color: '#2f8078',
              size: 16,
              border: { width: 1, color: '#16534e' }
            },
            edge: {
              label: '${properties.label}',
              color: '#8b9aa0',
              width: 2
            }
          },
          settings: {
            layout: oracleLayout,
            searchEnabled: true,
            groupEdges: false,
            showTitle: false,
            vertexLabelProperty: 'properties.name',
            edgeLabelProperty: 'properties.label',
            edgeMarker: 'arrow',
            legendWidth: 220,
            defaultLegendEnabled: true,
            legendState: 'expanded',
            tooltipCharLimit: 180,
            theme: 'light',
            defaults: {
              interactionActive: false,
              fitToScreenActive: true,
              stickyActive: false
            }
          },
          featureFlags: {
            exploration: { expand: true, focus: true, group: false, ungroup: false, drop: false, undo: true, redo: true, reset: true },
            modes: { interaction: true, fitToScreen: true, sticky: true, evolution: false, reachabilityPaths: false },
            displaySizeControl: false
          }
        }
      });
    } catch (error) {
      setRenderError(error.message || 'The Oracle graph visualization could not be loaded.');
    }
    return () => {
      visualization?.$destroy();
    };
  }, [graph, vertices.length, layoutType]);

  return (
    <section className="panel graph-panel" id="graph">
      <div className="panel-header">
        <div><p className="eyebrow">SQL Property Graph</p><h2>Recall relationship graph</h2><TechTags items={['Graph', 'DDS']} /></div>
        <span className="panel-count"><Boxes size={14} /> {vertices.length} vertices · {edges.length} edges</span>
      </div>
      <div className="graph-intro"><GitGraph size={15} /><span>Oracle Graph Visualization Library 26.3 renders the shared component and supplier trace plus the active persona's DDS-filtered stores and customers. Click a node to focus its relationships.</span></div>
      <div className="graph-canvas">
        <div ref={targetRef} className="oracle-graph-root" />
        {showFallback && <RecallGraphFallback vertices={vertices} edges={edges} layoutType={layoutType} onLayoutTypeChange={setLayoutType} />}
        {renderError && <div className="graph-error"><CircleAlert size={18} /><span>{renderError}</span></div>}
      </div>
    </section>
  );
}

function ChatPanel({ batchId }) {
  const [messages, setMessages] = useState([{ role: 'assistant', text: 'I can answer questions using only the recall evidence authorized for this signed-in persona.' }]);
  const [question, setQuestion] = useState('');
  const [busy, setBusy] = useState(false);

  async function ask(text = question) {
    const clean = text.trim();
    if (!clean || busy) return;
    setMessages((current) => [...current, { role: 'user', text: clean }]);
    setQuestion('');
    setBusy(true);
    try {
      const result = await api('/api/agent', { method: 'POST', body: JSON.stringify({ batchId, question: clean }) });
      setMessages((current) => [...current, { role: 'assistant', text: result.answer }]);
    } catch (error) {
      setMessages((current) => [...current, { role: 'error', text: error.message }]);
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="panel chat-panel" id="chat">
      <div className="panel-header"><div><p className="eyebrow">Select AI Agent</p><h2>Ask the recall assistant</h2><TechTags items={['Agent', 'JSON', 'Spatial', 'Graph', 'Vector', 'DDS']} /></div><div className="chat-header-actions"><span className="agent-status"><span /> Live secured call</span><button className="icon-button" type="button" onClick={() => { setMessages([{ role: 'assistant', text: 'I can answer questions using only the recall evidence authorized for this signed-in persona.' }]); setQuestion(''); }} disabled={busy} aria-label="Clear conversation" title="Clear conversation"><Trash2 size={15} /></button></div></div>
      <div className="chat-messages">{messages.map((message, index) => <div className={`chat-message ${message.role}`} key={`${message.role}-${index}`}>{message.role === 'assistant' && <div className="assistant-avatar"><Sparkles size={14} /></div>}<div className="message-bubble">{message.text}</div></div>)}{busy && <div className="chat-message assistant"><div className="assistant-avatar"><Sparkles size={14} /></div><div className="message-bubble typing">Reading authorized evidence <span /><span /><span /></div></div>}</div>
      <div className="starter-questions" aria-label="Example agent questions"><p>Example questions</p>{starterQuestions.map((starter) => <button type="button" key={starter} onClick={() => ask(starter)} disabled={busy}>{starter}</button>)}</div>
      <form className="chat-input" onSubmit={(event) => { event.preventDefault(); ask(); }}><input value={question} onChange={(event) => setQuestion(event.target.value)} placeholder="Ask about B-482..." disabled={busy} /><button type="submit" aria-label="Send question" title="Send question" disabled={busy || !question.trim()}><Send size={17} /></button></form>
      <p className="chat-footnote"><ShieldCheck size={13} /> JSON, vector, spatial, and graph evidence is retrieved as this user before the server-side agent handoff.</p>
    </section>
  );
}

function App() {
  const [identity, setIdentity] = useState(null);
  const [bundle, setBundle] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  async function loadBundle() {
    setLoading(true);
    setError('');
    try {
      const result = await api('/api/recall/B-482');
      setIdentity(result.identity);
      setBundle(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    api('/api/session').then((result) => { setIdentity(result.identity); return loadBundle(); }).catch(() => setLoading(false));
  }, []);

  async function logout() {
    await api('/api/auth/logout', { method: 'POST' }).catch(() => {});
    setIdentity(null);
    setBundle(null);
  }

  if (!identity && !loading) return <Login onLogin={(nextIdentity) => { setIdentity(nextIdentity); loadBundle(); }} />;
  if (loading || !bundle) return <div className="loading-shell"><div className="loading-spinner" /><p>Opening secured recall workspace...</p></div>;
  if (error) return <div className="loading-shell"><CircleAlert size={28} /><h2>Unable to load the recall workspace</h2><p>{error}</p><button className="primary-button" onClick={logout}>Return to sign in</button></div>;

  const context = bundle.context || {};
  const product = bundle.product || {};
  return (
    <main className="app-shell">
      <aside className="sidebar">
        <div className="brand-mark sidebar-brand"><span>O</span><div>Oracle AI Database <b>26ai</b></div></div>
        <div className="sidebar-title"><span className="pulse-dot" /> Recall operations</div>
        <nav className="side-nav" aria-label="Recall workspace sections">
          <a className="active" href="#overview"><Activity size={17} /> Overview</a>
          <a href="#map"><MapPinned size={17} /> Store map</a>
          <a href="#evidence"><FileSearch size={17} /> Evidence</a>
          <a href="#graph"><GitGraph size={17} /> Property graph</a>
          <a href="#chat"><MessageCircle size={17} /> Agent chat</a>
        </nav>
        <div className="sidebar-bottom"><div className="converged-badge"><span><Boxes size={17} /></span><div><b>Converged evidence</b><small>JSON · Spatial · Graph · Vector · Agent</small></div></div><div className="security-badge"><ShieldCheck size={15} /><span>Deep Data Security active</span></div></div>
      </aside>

      <section className="workspace" id="overview">
        <header className="topbar"><div className="mobile-title"><span className="pulse-dot" /> Recall operations</div><div className="topbar-actions"><div className="batch-selector"><span>Active batch</span><b>{context.batchId || 'B-482'}</b><ChevronRight size={15} /></div><div className="identity-chip"><div className="identity-avatar">{identity.username?.slice(0, 2)}</div><div><b>{identity.roleLabel}</b><span>{identity.username}</span></div><button type="button" onClick={logout} title="Sign out" aria-label="Sign out"><LogOut size={16} /></button></div></div></header>
        <div className="content">
          <section className="page-heading"><div><p className="eyebrow">Live incident · {product.recallStatus || 'INVESTIGATING'}</p><h1>Recall command center</h1><p>Role-aware evidence for <b>{product.product || 'HeatPro Countertop Cooker'}</b> · {context.batchId || 'B-482'}</p></div><div className="heading-actions"><span className="protected-tag"><ShieldCheck size={15} /> Authorized session</span><button className="icon-button" onClick={loadBundle} title="Refresh secured evidence" aria-label="Refresh secured evidence"><Activity size={17} /></button></div></section>
          <section className="stats-grid"><StatCard icon={Store} label="Visible stores" value={formatNumber(context.affectedStoreCount)} detail="within your role scope" tone="teal" /><StatCard icon={PackageSearch} label="Units in scope" value={formatNumber(context.unitsSent)} detail="shipped in batch B-482" tone="orange" /><StatCard icon={Users} label="Exposed customers" value={formatNumber(context.customerExposureCount)} detail="authorized count only" tone="blue" /><StatCard icon={FileSearch} label="Priority complaints" value={formatNumber(context.semanticComplaints?.length)} detail="vector-ranked evidence" tone="red" /></section>
          <div className="main-grid"><MapPanel stores={bundle.stores} /><RegionBars stores={bundle.stores} /><ProductPanel product={product} /><ComplaintPanel batchId={context.batchId || 'B-482'} complaints={context.semanticComplaints} /><GraphPanel graph={bundle.graph} /><ChatPanel batchId={context.batchId || 'B-482'} /></div>
        </div>
      </section>
    </main>
  );
}

export default App;
