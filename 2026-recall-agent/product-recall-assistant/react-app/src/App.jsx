import { Fragment, useEffect, useMemo, useRef, useState } from 'react';
import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet';
import L from 'leaflet';
import GraphVisualization from './vendor/oracle-graph-visualization/runtime.js';
import {
  Activity,
  ArrowUpRight,
  Banknote,
  CheckCircle2,
  ClipboardCheck,
  Bot,
  Braces,
  Boxes,
  ChevronLeft,
  ChevronRight,
  CircleAlert,
  FileSearch,
  GitGraph,
  LogOut,
  LockKeyhole,
  Mail,
  MapPinned,
  Megaphone,
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

const ddsPolicyFallbacks = {
  STORE_101_USER: {
    name: 'DG_STORE_101_STORES',
    dataRole: 'RECALL_STORE_101_DATA_ROLE',
    scope: 'Store 101 and its authorized downstream evidence',
    rule: 'STORE_ID = 101'
  },
  REGION_NE_USER: {
    name: 'DG_REGION_NE_STORES',
    dataRole: 'RECALL_REGION_NE_DATA_ROLE',
    scope: 'Northeast stores and their authorized downstream evidence',
    rule: "REGION_CODE = 'NORTHEAST'"
  },
  RECALL_LEAD_USER: {
    name: 'DG_LEAD_STORES',
    dataRole: 'RECALL_LEAD_DATA_ROLE',
    scope: 'All stores and company-wide authorized evidence',
    rule: 'All stores'
  }
};

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
            <div><strong>310</strong><span>complaints</span></div>
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

const ddsPersonaDetails = [
  { username: 'STORE_101_USER', label: 'Store associate', hint: 'Store 101', coverage: '1 store · 5 customers', icon: Store },
  { username: 'REGION_NE_USER', label: 'Northeast manager', hint: 'Northeast region', coverage: '24 stores · 120 customers', icon: MapPinned },
  { username: 'RECALL_LEAD_USER', label: 'Recall response lead', hint: 'Company-wide', coverage: '120 stores · 600 customers', icon: ShieldCheck }
].map((persona) => ({ ...persona, ...ddsPolicyFallbacks[persona.username] }));

function DdsPersonaPanel({ identity }) {
  return (
    <section className="panel persona-dds-panel" aria-label="Application users mapped to Deep Data Security personas">
      <div className="panel-header">
        <div><p className="eyebrow">Identity and authorization</p><h2>Application users mapped to DDS personas</h2><TechTags items={['DDS']} /></div>
        <span className="panel-count"><Users size={14} /> {ddsPersonaDetails.length} personas</span>
      </div>
      <div className="persona-dds-grid">
        {ddsPersonaDetails.map(({ username, label, hint, coverage, icon: Icon, ...fallbackPolicy }) => {
          const active = identity.username === username;
          const policy = active
            ? { ...fallbackPolicy, ...(identity.ddsPolicy || {}), ...(identity.dataRole ? { dataRole: identity.dataRole } : {}) }
            : fallbackPolicy;
          return <article className={`persona-dds-card${active ? ' active' : ''}`} key={username}>
            <div className="persona-dds-card-header">
              <div className="persona-dds-icon"><Icon size={16} /></div>
              <div className="persona-dds-card-title"><div><b>{label}</b>{active && <span className="persona-dds-current">Current login</span>}</div><code>{username}</code></div>
            </div>
            <p className="persona-dds-coverage"><b>{hint}</b> · {coverage}</p>
            <dl className="persona-dds-details">
              <div><dt>DDS policy</dt><dd>{policy.name}</dd></div>
              <div><dt>Data role</dt><dd>{policy.dataRole}</dd></div>
              <div><dt>Scope rule</dt><dd>{policy.rule}</dd></div>
            </dl>
          </article>;
        })}
      </div>
    </section>
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

function StoreDataTable({ stores }) {
  const rows = [...(stores?.features || [])].sort((left, right) => Number(left.properties?.storeId) - Number(right.properties?.storeId));
  return <section className="panel store-data-panel">
    <div className="panel-header compact"><div><p className="eyebrow">Spatial source data</p><h2>Authorized store records</h2><TechTags items={['Spatial', 'DDS']} /></div><span className="panel-count"><Store size={14} /> {rows.length} stores</span></div>
    <div className="store-data-scroll"><table><thead><tr><th>Store ID</th><th>Store</th><th>Region</th><th>Units sent</th><th>Longitude</th><th>Latitude</th></tr></thead><tbody>{rows.map((feature) => { const properties = feature.properties || {}; const [longitude, latitude] = feature.geometry?.coordinates || []; return <tr key={properties.storeId}><td>{properties.storeId}</td><td><b>{properties.storeCode}</b><span>{properties.storeName}</span></td><td>{properties.regionCode}</td><td>{formatNumber(properties.unitsSent)}</td><td>{Number(longitude).toFixed(4)}</td><td>{Number(latitude).toFixed(4)}</td></tr>; })}</tbody></table></div>
  </section>;
}

function ProductPanel({ product, jsonOnly = false, selectedEvidence, onClearSelectedEvidence }) {
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
      {selectedEvidence && <div className="selected-evidence-json">
        <div className="selected-evidence-heading"><div><p className="eyebrow">Selected vector record</p><strong>Complaint {selectedEvidence.complaintId}</strong></div><button type="button" onClick={onClearSelectedEvidence} aria-label="Clear selected complaint record" title="Clear selected complaint record"><X size={14} /></button></div>
        <div className="selected-evidence-meta"><span><b>Distance</b>{selectedEvidence.distance ?? '—'}</span><span><b>Severity</b>{selectedEvidence.severity || '—'}</span><span><b>Symptom</b>{selectedEvidence.symptom || '—'}</span></div>
        <pre>{JSON.stringify(selectedEvidence, null, 2)}</pre>
      </div>}
      {!jsonOnly && <div className="product-view-switch" role="tablist" aria-label="Product data view"><button type="button" className={productView === 'json' ? 'active' : ''} role="tab" aria-selected={productView === 'json'} onClick={() => setProductView('json')}><Braces size={14} /> JSON document</button><button type="button" className={productView === 'relational' ? 'active' : ''} role="tab" aria-selected={productView === 'relational'} onClick={() => setProductView('relational')}><Table2 size={14} /> Relational view</button></div>}
      {jsonOnly || productView === 'json' ? <div className="product-json-view"><div className="product-view-caption"><Braces size={14} /><span>Native JSON payload returned by the product context API</span></div><pre>{JSON.stringify(product || {}, null, 2)}</pre></div> : <div className="product-relational-view"><div className="product-view-caption"><Table2 size={14} /><span>Relational projection of the same JSON document</span></div><div className="relational-field-list">{relationalFields.map(([field, value]) => <div key={field}><b>{field}</b><span>{String(value ?? 'null')}</span></div>)}</div><div className="relational-components"><b>PRODUCT_COMPONENTS</b><div className="relational-component-table"><span>COMPONENT_CODE</span><span>COMPONENT_NAME</span><span>CRITICALITY</span>{components.map((component) => <Fragment key={component.code}><span>{component.code}</span><span>{component.name}</span><span>{component.criticality}</span></Fragment>)}</div></div></div>}
      <div className="issue-callout"><CircleAlert size={17} /><div><b>Thermal-risk investigation</b><p>{product?.issueSummary}</p></div></div>
      <div className="component-section"><div className="section-label"><Boxes size={15} /> Product components</div><div className="component-list">{components.slice(0, 8).map((component) => <span key={component.code} title={`${component.name} · ${component.criticality}`}>{component.code}</span>)}</div><p className="component-footnote">{components.length} traceable components in the product definition</p></div>
    </section>
  );
}

function ComplaintPanel({ batchId, onSelectEvidence }) {
  const [query, setQuery] = useState('');
  const [rows, setRows] = useState([]);
  const [searching, setSearching] = useState(false);
  const [searched, setSearched] = useState(false);
  const hasSearchResults = searched && rows.length > 0;

  useEffect(() => {
    setRows([]);
    setSearched(false);
  }, [batchId]);

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

  function changeQuery(event) {
    setQuery(event.target.value);
    // Results belong only to the exact query that produced them. Clearing
    // while the user edits prevents old evidence from appearing as a default.
    if (searched) {
      setRows([]);
      setSearched(false);
    }
  }

  function clearSearch() {
    setQuery('');
    setRows([]);
    setSearched(false);
  }

  return (
    <section className="panel complaint-panel">
      <div className="panel-header compact"><div><p className="eyebrow">Vector evidence</p><h2>Priority complaints</h2></div><FileSearch size={17} className="panel-action" /></div>
      <form className="vector-search" onSubmit={searchEvidence}>
        <Search size={15} />
        <button type="button" className="vector-search-clear" onClick={clearSearch} disabled={!query && !searched && !rows.length} title="Clear vector search" aria-label="Clear vector search"><Trash2 size={15} /></button>
        <input value={query} onChange={changeQuery} placeholder="Search symptoms or complaint evidence" aria-label="Search symptoms or complaint evidence" />
        <button type="submit" disabled={!query.trim() || searching} title="Search authorized complaint vectors" aria-label="Search authorized complaint vectors"><Search size={15} /></button>
      </form>
      <p className="vector-search-note">{searched ? 'Showing your authorized matches in ascending cosine distance (closest first).' : 'Enter symptoms or keywords, then run a vector search to see authorized evidence ranked by closest match.'}</p>
      <div className="complaint-list">
        {hasSearchResults ? rows.map((complaint) => <button className={`complaint-row${complaint.complaintId === 'ERR' ? ' error-row' : ''}`} type="button" onClick={() => onSelectEvidence?.(complaint)} disabled={complaint.complaintId === 'ERR'} key={`${complaint.complaintId}-${complaint.distance}`} aria-label={`Open complaint ${complaint.complaintId} in JSON Duality`}><div className="complaint-id">{complaint.complaintId}</div><div className="complaint-copy"><p>{complaint.text}</p><span>{complaint.distance === null ? 'Search unavailable' : `Cosine distance ${complaint.distance}`}</span></div><ChevronRight size={15} /></button>) : <div className="evidence-empty"><FileSearch size={18} /><span>{searched ? 'No authorized complaint vectors matched those terms.' : 'Search authorized complaint vectors to see ranked matches.'}</span></div>}
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

const graphRowLimitOptions = [25, 50, 75, 100];

function RecallGraphFallback({ vertices, edges, layoutType, onLayoutTypeChange, onDistanceChange }) {
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
  const setGraphDistance = (hops) => {
    setMaxHops(hops);
    // The full lead graph needs the canvas rather than a zoomed-out overview.
    setScale(hops >= 2 ? 1 : 0.72);
    onDistanceChange?.(hops);
  };
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
    return {
      nodes: positions,
      height,
      bounds: { minX, maxX, minY, maxY },
      center: { x: width / 2 - (minX + maxX) / 2, y: height / 2 - (minY + maxY) / 2 }
    };
  }, [displayVertices, displayEdges, layoutType]);
  const [nodes, setNodes] = useState(new Map());
  useEffect(() => {
    setNodes(new Map(layout.nodes));
    setOffset({
      // Keep the graph centered horizontally while preserving the fixed top
      // inset that prevents deeper traversals from dropping lower.
      x: width / (2 * scale) - (layout.bounds.minX + layout.bounds.maxX) / 2,
      y: 80 / scale - layout.bounds.minY
    });
    setSelectedEdge(null);
  }, [layout, maxHops]);
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
    setGraphDistance(1);
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
      <select value={maxHops} onChange={(event) => { const hops = Number(event.target.value); setGraphDistance(hops); setFocusedId(null); setSelectedNode(null); setSelectedEdge(null); }} aria-label="Graph distance in hops">
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
  const [maxHops, setMaxHops] = useState(1);
  const [rowLimit, setRowLimit] = useState(25);
  const [graphPage, setGraphPage] = useState(0);
  const showFallback = true;
  const vertices = graph?.vertices || [];
  const edges = graph?.edges || [];
  const batchVertex = vertices.find((vertex) => vertex.labels?.includes('batch'));
  const batchId = batchVertex ? String(batchVertex.id) : null;
  const pageCapacity = Math.max(1, rowLimit - (batchVertex ? 1 : 0));
  const graphPageCount = Math.max(1, Math.ceil((vertices.length - (batchVertex ? 1 : 0)) / pageCapacity));
  const currentGraphPage = Math.min(graphPage, graphPageCount - 1);
  const pageVertices = useMemo(() => {
    const remainingVertices = batchId
      ? vertices.filter((vertex) => String(vertex.id) !== batchId)
      : vertices;
    const start = currentGraphPage * pageCapacity;
    const visibleVertices = remainingVertices.slice(start, start + pageCapacity);
    return batchVertex ? [batchVertex, ...visibleVertices] : visibleVertices;
  }, [batchId, batchVertex, currentGraphPage, pageCapacity, vertices]);
  const pageVertexIds = useMemo(() => new Set(pageVertices.map((vertex) => String(vertex.id))), [pageVertices]);
  const pageEdges = useMemo(
    () => edges.filter((edge) => pageVertexIds.has(String(edge.source)) && pageVertexIds.has(String(edge.target))),
    [edges, pageVertexIds]
  );
  const pagedGraph = useMemo(
    () => graph ? { ...graph, vertices: pageVertices, edges: pageEdges } : graph,
    [graph, pageEdges, pageVertices]
  );

  useEffect(() => {
    setGraphPage(0);
  }, [graph]);

  const oracleLayout = layoutType === 'top-down'
    ? { type: 'hierarchical', rankDirection: 'TB', ranker: 'network-simplex', vertexSeparation: 58, edgeSeparation: 24, rankSeparation: 112 }
    : layoutType === 'left-right'
      ? { type: 'hierarchical', rankDirection: 'LR', ranker: 'network-simplex', vertexSeparation: 58, edgeSeparation: 24, rankSeparation: 112 }
      : layoutType === 'force'
        ? { type: 'force', spacing: 280, alphaDecay: 0.028, velocityDecay: 0.34, edgeDistance: 300, vertexCharge: -720, clusterEnabled: false }
        : { type: layoutType, spacing: 90 };

  useEffect(() => {
    if (!targetRef.current || !pagedGraph || !pageVertices.length) return undefined;
    setRenderError('');
    let visualization;
    try {
      visualization = new GraphVisualization({
        target: targetRef.current,
        props: {
          data: pagedGraph,
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
  }, [layoutType, pageVertices.length, pagedGraph]);

  return (
    <section className="panel graph-panel" id="graph">
      <div className="panel-header">
        <div><p className="eyebrow">SQL Property Graph</p><h2>Recall relationship graph</h2></div>
        <span className="panel-count"><Boxes size={14} /> {vertices.length} vertices · {edges.length} edges total</span>
      </div>
      <div className="graph-page-bar" aria-label="Graph pagination controls">
        <div className="graph-page-status">
          <strong>Showing {pageVertices.length} of {vertices.length} vertices</strong>
          <span>{pageEdges.length} connected edges on page {currentGraphPage + 1} of {graphPageCount} · The recall batch stays visible as the page anchor.</span>
        </div>
        <div className="graph-page-actions">
          <label className="graph-page-limit">
            <span>Rows per view</span>
            <select value={rowLimit} onChange={(event) => { setRowLimit(Number(event.target.value)); setGraphPage(0); }} aria-label="Graph rows per view">
              {graphRowLimitOptions.map((limit) => <option key={limit} value={limit}>{limit}</option>)}
            </select>
          </label>
          <button type="button" onClick={() => setGraphPage((page) => Math.max(0, page - 1))} disabled={currentGraphPage === 0} aria-label="Previous graph page" title="Previous graph page"><ChevronLeft size={15} /></button>
          <span className="graph-page-number">{currentGraphPage + 1} / {graphPageCount}</span>
          <button type="button" onClick={() => setGraphPage((page) => Math.min(graphPageCount - 1, page + 1))} disabled={currentGraphPage >= graphPageCount - 1} aria-label="Next graph page" title="Next graph page"><ChevronRight size={15} /></button>
        </div>
      </div>
      <div className="graph-canvas">
        <div ref={targetRef} className="oracle-graph-root" />
        {showFallback && <RecallGraphFallback vertices={pageVertices} edges={pageEdges} layoutType={layoutType} onLayoutTypeChange={setLayoutType} onDistanceChange={setMaxHops} />}
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
      <div className="panel-header"><div><p className="eyebrow">Select AI Agent</p><h2>Ask the recall assistant</h2></div><div className="chat-header-actions"><span className="agent-status"><span /> Live secured call</span><button className="icon-button" type="button" onClick={() => { setMessages([{ role: 'assistant', text: 'I can answer questions using only the recall evidence authorized for this signed-in persona.' }]); setQuestion(''); }} disabled={busy} aria-label="Clear conversation" title="Clear conversation"><Trash2 size={15} /></button></div></div>
      <div className="chat-messages">{messages.map((message, index) => <div className={`chat-message ${message.role}`} key={`${message.role}-${index}`}>{message.role === 'assistant' && <div className="assistant-avatar"><Sparkles size={14} /></div>}<div className="message-bubble">{message.text}</div></div>)}{busy && <div className="chat-message assistant"><div className="assistant-avatar"><Sparkles size={14} /></div><div className="message-bubble typing">Reading authorized evidence <span /><span /><span /></div></div>}</div>
      <div className="starter-questions" aria-label="Example agent questions"><p>Example questions</p>{starterQuestions.map((starter) => <button type="button" key={starter} onClick={() => ask(starter)} disabled={busy}>{starter}</button>)}</div>
      <form className="chat-input" onSubmit={(event) => { event.preventDefault(); ask(); }}><input value={question} onChange={(event) => setQuestion(event.target.value)} placeholder="Ask about B-482..." disabled={busy} /><button type="submit" aria-label="Send question" title="Send question" disabled={busy || !question.trim()}><Send size={17} /></button></form>
      <p className="chat-footnote"><ShieldCheck size={13} /> JSON, vector, spatial, and graph evidence is retrieved as this user before the server-side agent handoff.</p>
    </section>
  );
}

function parseNoticeTemplate(template) {
  if (!template) return {};
  try {
    const parsed = JSON.parse(template);
    if (parsed && typeof parsed === 'object') return parsed;
  } catch {
    // The agent is asked for JSON, but the raw response remains reviewable if
    // a provider returns a fenced or prose-wrapped answer.
  }
  return { body: template };
}

function mergeNoticeTemplate(template, recipient, product, batchId, refundSteps) {
  const customerName = recipient?.customerName || 'Customer';
  const values = {
    '{{customer_name}}': customerName,
    '{{ customer_name }}': customerName,
    '{{customerName}}': customerName,
    '{{product_name}}': recipient?.productName || product?.product || 'the recalled product',
    '{{sku}}': recipient?.sku || product?.sku || 'the affected item',
    '{{batch_id}}': recipient?.batchId || batchId,
    '{{refund_amount}}': recipient?.refundAmount == null ? '{{refund_amount}}' : `$${Number(recipient.refundAmount).toFixed(2)}`,
    '{{refund_steps}}': refundSteps || '{{refund_steps}}'
  };
  return Object.entries(values).reduce((text, [token, value]) => text.split(token).join(String(value)), String(template || ''));
}

function ensureCustomerNameInBody(body, recipient, channel) {
  const customerName = String(recipient?.customerName || '').trim();
  const renderedBody = String(body || '').trim();
  if (!customerName || renderedBody.toLocaleLowerCase().includes(customerName.toLocaleLowerCase())) return renderedBody;
  const greeting = channel === 'SMS' ? `Hi ${customerName},` : `Hello ${customerName},`;
  return `${greeting}\n\n${renderedBody}`.trim();
}

function CampaignPanel({ batchId, identity, product }) {
  const [campaignState, setCampaignState] = useState(null);
  const [channel, setChannel] = useState('EMAIL');
  const [tone, setTone] = useState('PROFESSIONAL');
  const [selectedCustomerId, setSelectedCustomerId] = useState('');
  const [customerOptions, setCustomerOptions] = useState([]);
  const [personalizedNotice, setPersonalizedNotice] = useState(null);
  const [busyAction, setBusyAction] = useState('');
  const [error, setError] = useState('');
  const autoDraftKeyRef = useRef('');

  async function loadCampaign() {
    setError('');
    autoDraftKeyRef.current = '';
    try {
      const result = await api(`/api/campaign?batchId=${encodeURIComponent(batchId)}`);
      // Keep the saved campaign in the database for audit, but start this
      // workspace with a blank preview so Generate always means a new draft.
      setCampaignState({ ...result, campaign: null });
      setSelectedCustomerId('');
      setCustomerOptions([]);
      setPersonalizedNotice(null);
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  useEffect(() => {
    loadCampaign();
  }, [batchId]);

  async function runAction(action, path, body) {
    if (busyAction) return;
    setBusyAction(action);
    setError('');
    try {
      const result = await api(path, { method: 'POST', body: JSON.stringify(body || {}) });
      setCampaignState(action === 'authorize' ? { ...result, campaign: null } : result);
      if (action === 'draft') {
        setCustomerOptions([]);
        setSelectedCustomerId('');
        setPersonalizedNotice(null);
      }
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setBusyAction('');
    }
  }

  async function personalizeNotice() {
    const purchaseId = Number(selectedCustomerId);
    const campaignId = Number(campaignState?.campaign?.campaignId);
    if (!Number.isInteger(purchaseId) || !Number.isInteger(campaignId) || busyAction) return;
    setBusyAction('personalize');
    setError('');
    try {
      const result = await api('/api/campaign/personalize', { method: 'POST', body: JSON.stringify({ campaignId, purchaseId }) });
      setCampaignState(result.state);
      setPersonalizedNotice(result.personalizedNotice || null);
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setBusyAction('');
    }
  }

  function clearDraftPreview() {
    setCampaignState((current) => current ? { ...current, campaign: null } : current);
    setSelectedCustomerId('');
    setCustomerOptions([]);
    setPersonalizedNotice(null);
    setError('');
  }

  const policy = campaignState?.policy || {};
  const contactAuthorized = policy.contactAuthorized === true || policy.contactAuthorized === 'true';
  const campaign = campaignState?.campaign || null;
  useEffect(() => {
    const autoDraftKey = `${batchId}:${channel}:${tone}`;
    if (!contactAuthorized || campaign?.campaignId || busyAction || autoDraftKeyRef.current === autoDraftKey) return;
    autoDraftKeyRef.current = autoDraftKey;
    runAction('draft', '/api/campaign/draft', { batchId, channel, tone });
  }, [batchId, channel, tone, contactAuthorized, campaign?.campaignId, busyAction]);
  useEffect(() => {
    if (!campaign?.campaignId || !contactAuthorized) return;
    let active = true;
    api(`/api/campaign/customers?batchId=${encodeURIComponent(batchId)}`)
      .then((result) => { if (active) setCustomerOptions(result.customers || []); })
      .catch((requestError) => { if (active) setError(requestError.message); });
    return () => { active = false; };
  }, [batchId, campaign?.campaignId, contactAuthorized]);
  useEffect(() => {
    if (!customerOptions.length) {
      setSelectedCustomerId('');
      return;
    }
    if (!customerOptions.some((customer) => String(customer.purchaseId) === selectedCustomerId)) {
      setSelectedCustomerId(String(customerOptions[0].purchaseId));
    }
  }, [campaign?.campaignId, customerOptions, selectedCustomerId]);
  const parsedTemplate = parseNoticeTemplate(personalizedNotice?.template || campaign?.template);
  const previewRecipient = customerOptions.find((customer) => String(customer.purchaseId) === selectedCustomerId) || customerOptions[0];
  const previewSubject = personalizedNotice
    ? mergeNoticeTemplate(parsedTemplate.subject || 'Recall notice for {{product_name}}', previewRecipient, product, batchId, policy.refundSteps)
    : (parsedTemplate.subject || 'Recall notice template');
  const previewBody = personalizedNotice
    ? ensureCustomerNameInBody(
      mergeNoticeTemplate(parsedTemplate.body || campaign?.template || 'The notice template is ready for review.', previewRecipient, product, batchId, policy.refundSteps),
      previewRecipient,
      campaign?.channel
    ) + `\n\nOrder / purchase ID: ${previewRecipient?.orderReference || `PUR-${previewRecipient?.purchaseId || ''}`} · Quantity: ${previewRecipient?.quantity ?? ''} · Approved refund: $${Number(previewRecipient?.refundAmount || 0).toFixed(2)}`
    : (parsedTemplate.body || campaign?.template || 'The notice template is ready for review.');
  const totalRefund = Number(campaign?.totalRefund || 0);
  const canAuthorize = identity.username === 'RECALL_LEAD_USER' && !contactAuthorized;
  const canApprove = identity.username === 'RECALL_LEAD_USER' && campaign?.status === 'DRAFT';

  return (
    <section className="panel campaign-panel" id="campaign" role="tabpanel" aria-label="Recall response campaign">
      <div className="panel-header">
        <div><p className="eyebrow">Lab 8 · Governed response</p><h2>Create recall notice campaign</h2></div>
        <div className="campaign-header-status"><span className={`campaign-status-dot${contactAuthorized ? ' ready' : ''}`} /> {contactAuthorized ? 'Contact authorized' : 'Approval required'}</div>
      </div>
      <div className="campaign-intro">
        <div className="campaign-intro-icon"><Megaphone size={19} /></div>
        <div><strong>From evidence to an approved customer response</strong><p>The database determines the authorized audience, item, batch, quantity, and refund intent. Select AI Agent drafts the language; a recall lead approves the campaign before any notice or refund workflow can proceed.</p></div>
      </div>
      {error && <div className="campaign-error"><CircleAlert size={16} /><span>{error}</span></div>}
      <div className="campaign-grid">
        <div className="campaign-control-column">
          <div className="campaign-policy-card">
            <div className="campaign-section-heading"><LockKeyhole size={15} /><span>Contact authorization</span></div>
            <div className="campaign-policy-value"><strong>{contactAuthorized ? 'Authorized for B-482' : 'Not yet authorized'}</strong><span>{contactAuthorized ? `Approved by ${policy.authorizedBy || 'recall lead'}` : 'The investigation starts with customer contact disabled.'}</span></div>
            {canAuthorize && <button className="primary-button campaign-action-button" type="button" onClick={() => runAction('authorize', '/api/campaign/authorize', { batchId })} disabled={Boolean(busyAction)}>{busyAction === 'authorize' ? 'Authorizing…' : 'Authorize customer contact'} <CheckCircle2 size={15} /></button>}
            {!canAuthorize && !contactAuthorized && <p className="campaign-helper"><ShieldCheck size={13} /> Sign in as the Recall response lead to authorize this step.</p>}
          </div>
          <div className="campaign-form-card">
            <div className="campaign-section-heading"><ClipboardCheck size={15} /><span>Draft settings</span></div>
            <label htmlFor="campaign-channel">Notice channel</label>
            <select id="campaign-channel" value={channel} onChange={(event) => setChannel(event.target.value)} disabled={!contactAuthorized || Boolean(busyAction)}><option value="EMAIL">Email notice</option><option value="SMS">SMS notice</option></select>
            <label htmlFor="campaign-tone">Notice tone</label>
            <select id="campaign-tone" value={tone} onChange={(event) => setTone(event.target.value)} disabled={!contactAuthorized || Boolean(busyAction)}><option value="PROFESSIONAL">Professional</option><option value="REASSURING">Reassuring</option><option value="CONCISE">Concise</option></select>
            <button className="primary-button campaign-action-button" type="button" onClick={() => runAction('draft', '/api/campaign/draft', { batchId, channel, tone })} disabled={!contactAuthorized || Boolean(busyAction)}>{busyAction === 'draft' ? 'Drafting with Select AI…' : campaign ? 'Regenerate generic draft' : 'Generate generic draft'} <Mail size={15} /></button>
            <p className="campaign-helper"><ShieldCheck size={13} /> A generic draft is generated automatically when this authorized workspace opens. No customer records are inserted until you select one authorized customer and generate that personalized notice. Email addresses never go to the model.</p>
          </div>
        </div>
        <div className="campaign-preview-column">
          <div className="campaign-preview-card">
            <div className="campaign-preview-heading"><div><p className="eyebrow">Campaign preview</p><strong>{campaign ? `Campaign #${campaign.campaignId}` : 'New draft workspace'}</strong></div>{campaign && <div className="campaign-preview-heading-actions"><button className="campaign-clear-button" type="button" onClick={clearDraftPreview} disabled={Boolean(busyAction)}><Trash2 size={13} /> Clear preview</button><span className={`campaign-badge ${campaign.status.toLowerCase()}`}>{campaign.status}</span></div>}</div>
            {!campaign ? <div className="campaign-empty"><Mail size={22} /><span>{contactAuthorized ? 'Generating the generic notice draft, then loading the authorized customer orders…' : 'Authorize customer contact to generate the generic notice draft and load the authorized customer orders.'}</span></div> : <>
              <div className="campaign-metrics"><div><span>Eligible audience</span><strong>{customerOptions.length ? formatNumber(customerOptions.length) : '…'}</strong><small>DDS-authorized purchases</small></div><div><span>Personalized</span><strong>{formatNumber(campaign.recipientCount)}</strong><small>customer record{Number(campaign.recipientCount) === 1 ? '' : 's'} materialized</small></div><div><span>Generated by</span><strong>{campaign.templateSource === 'SELECT_AI_AGENT' ? 'Select AI' : 'Fallback'}</strong><small>human review required</small></div></div>
              <div className="campaign-customer-picker"><div><label htmlFor="campaign-customer">Customer and order</label><small>{formatNumber(customerOptions.length)} DDS-authorized order{customerOptions.length === 1 ? '' : 's'} available for a one-at-a-time personalized draft</small></div><select id="campaign-customer" value={selectedCustomerId} onChange={(event) => { setSelectedCustomerId(event.target.value); setPersonalizedNotice(null); }} disabled={!customerOptions.length || Boolean(busyAction)}><option value="" disabled>{customerOptions.length ? 'Select a customer order' : 'Loading authorized customer orders…'}</option>{customerOptions.map((customer) => <option key={String(customer.purchaseId)} value={String(customer.purchaseId)}>{customer.customerName || `Customer ${customer.customerId}`} · order {customer.orderReference || `PUR-${customer.purchaseId}`}</option>)}</select><button className="primary-button campaign-action-button" type="button" onClick={personalizeNotice} disabled={!selectedCustomerId || Boolean(busyAction)}>{busyAction === 'personalize' ? 'Generating personalized notice…' : 'Generate for selected customer'} <Mail size={15} /></button></div>
              <div className="campaign-notice-preview"><div className="campaign-notice-label"><Mail size={13} /> {campaign.channel} · {campaign.tone} {personalizedNotice ? '· Personalized' : '· Generic template'}</div><h3>{previewSubject}</h3><p>{previewBody}</p></div>
              <div className="campaign-recipient-heading"><span>DDS-authorized customer order</span><small>{previewRecipient ? 'Selected record used for the personalized draft' : 'Choose an authorized customer order above'}</small></div>
              {previewRecipient && <div className="campaign-recipient-card"><div className="campaign-recipient-avatar"><Users size={15} /></div><div><strong>{previewRecipient.customerName}</strong><span>{product?.product || campaign.productName} · batch {batchId} · order {previewRecipient.orderReference || `PUR-${previewRecipient.purchaseId}`} · {previewRecipient.quantity} unit{Number(previewRecipient.quantity) === 1 ? '' : 's'}</span></div><b>{personalizedNotice ? 'Drafted' : 'Selected'}</b></div>}
              {canApprove && <button className="primary-button campaign-approve-button" type="button" onClick={() => runAction('approve', '/api/campaign/approve', { campaignId: campaign.campaignId })} disabled={Boolean(busyAction)}>{busyAction === 'approve' ? 'Approving campaign…' : 'Approve campaign and create refund intents'} <Banknote size={15} /></button>}
              {campaign.status === 'APPROVED' && <div className="campaign-approved-note"><CheckCircle2 size={16} /><span>Approved. {formatNumber(campaign.recipientCount)} selected-customer refund intent{Number(campaign.recipientCount) === 1 ? ' is' : 's are'} ready for a provider or manual review. No funds were moved.</span></div>}
            </>}
          </div>
        </div>
      </div>
    </section>
  );
}

const sharedDataGrantObjects = [
  ['DG_PRODUCTS_READ', 'PRODUCTS'],
  ['DG_BATCHES_READ', 'BATCHES'],
  ['DG_ACTIONS_READ', 'RECALL_ACTIONS'],
  ['DG_QUERIES_READ', 'RECALL_QUERIES'],
  ['DG_RESPONSE_CENTERS_READ', 'RESPONSE_CENTERS'],
  ['DG_SUPPLIERS_READ', 'SUPPLIERS'],
  ['DG_SUPPLIER_SITES_READ', 'SUPPLIER_SITES'],
  ['DG_COMPONENTS_READ', 'COMPONENTS'],
  ['DG_COMPONENT_BATCHES_READ', 'COMPONENT_BATCHES'],
  ['DG_BATCH_COMPONENTS_READ', 'BATCH_COMPONENTS'],
  ['DG_COMPONENT_SITE_EDGES_READ', 'COMPONENT_BATCH_SITE_EDGES'],
  ['DG_COMPONENT_TYPE_EDGES_READ', 'COMPONENT_BATCH_COMPONENT_EDGES'],
  ['DG_SUPPLIER_SITE_EDGES_READ', 'SUPPLIER_SITE_EDGES']
];
const allRecallDataRoles = 'RECALL_STORE_101_DATA_ROLE, RECALL_REGION_NE_DATA_ROLE, RECALL_LEAD_DATA_ROLE';

function dataGrantStatements(role, username) {
  const storeGrant = username === 'STORE_101_USER'
    ? 'CREATE OR REPLACE DATA GRANT RECALL_OWNER.DG_STORE_101_STORES\n  AS SELECT ON RECALL_OWNER.STORES\n  WHERE STORE_ID = 101\n  TO ' + role + ';'
    : username === 'REGION_NE_USER'
      ? "CREATE OR REPLACE DATA GRANT RECALL_OWNER.DG_REGION_NE_STORES\n  AS SELECT ON RECALL_OWNER.STORES\n  WHERE REGION_CODE = 'NORTHEAST'\n  TO " + role + ';'
      : 'CREATE OR REPLACE DATA GRANT RECALL_OWNER.DG_LEAD_STORES\n  AS SELECT ON RECALL_OWNER.STORES\n  TO ' + role + ';';
  const shared = sharedDataGrantObjects.map(([grant, object]) => `CREATE OR REPLACE DATA GRANT RECALL_OWNER.${grant}\n  AS SELECT ON RECALL_OWNER.${object}\n  TO ${allRecallDataRoles};`);
  const downstream = [
    ['DG_STORE_CUSTOMERS', 'CUSTOMERS', 'HOME_STORE_ID IN (SELECT STORE_ID FROM RECALL_OWNER.STORES)'],
    ['DG_STORE_PURCHASES', 'PURCHASES', 'STORE_ID IN (SELECT STORE_ID FROM RECALL_OWNER.STORES)'],
    ['DG_STORE_SHIPMENT_ITEMS', 'SHIPMENT_ITEMS', 'STORE_ID IN (SELECT STORE_ID FROM RECALL_OWNER.STORES)'],
    ['DG_STORE_SHIPMENTS', 'SHIPMENTS', 'SHIPMENT_ID IN (SELECT SHIPMENT_ID FROM RECALL_OWNER.SHIPMENT_ITEMS)'],
    ['DG_CUSTOMER_COMPLAINTS', 'COMPLAINTS', 'CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM RECALL_OWNER.CUSTOMERS)'],
    ['DG_COMPLAINT_CHUNKS', 'COMPLAINT_CHUNKS', 'COMPLAINT_ID IN (SELECT COMPLAINT_ID FROM RECALL_OWNER.COMPLAINTS)']
  ].map(([grant, object, predicate]) => `CREATE OR REPLACE DATA GRANT RECALL_OWNER.${grant}\n  AS SELECT ON RECALL_OWNER.${object}\n  WHERE ${predicate}\n  TO ${allRecallDataRoles};`);
  return [...shared, storeGrant, ...downstream];
}

function DeepDataSecurityPanel({ identity }) {
  const policy = identity.ddsPolicy || ddsPolicyFallbacks[identity.username] || {};
  const role = policy.dataRole || identity.dataRole || 'ACTIVE_END_USER_ROLE';
  const grants = dataGrantStatements(role, identity.username);
  const scopeGrantIndex = sharedDataGrantObjects.length;
  const sharedGrants = grants.slice(0, scopeGrantIndex);
  const scopeGrant = grants[scopeGrantIndex];
  const downstreamGrants = grants.slice(scopeGrantIndex + 1);
  return <section className="panel dds-detail-panel" id="dds">
    <div className="panel-header"><div><p className="eyebrow">Oracle Deep Data Security</p><h2>Role-scoped data grants</h2><TechTags items={['DDS']} /></div><span className="panel-count"><ShieldCheck size={14} /> {grants.length} data grants</span></div>
    <div className="dds-detail-intro"><ShieldCheck size={17} /><div><b>{identity.roleLabel}</b><span>{policy.scope || 'Role-filtered recall evidence'}. The user receives one data role; the role receives the data grants below.</span></div></div>
    <div className="dds-ddl-section"><div className="dds-ddl-heading"><span>1</span><div><b>Assign the data role to the end user</b><small>Executed by the database administrator.</small></div></div><pre><code>{`GRANT DATA ROLE ${role} TO ${identity.username};`}</code></pre></div>
    <div className="dds-ddl-section"><div className="dds-ddl-heading"><span>2</span><div><b>Create the data grants that authorize this role</b><small>Shared grants list all three roles; the highlighted store grant establishes this user’s scope.</small></div></div><pre><code>{sharedGrants.join('\n\n')}</code></pre><div className="dds-scope-grant"><div><ShieldCheck size={16} /><span>Scope-defining data grant</span><b>{policy.rule || 'Active role scope'}</b></div><pre><code>{scopeGrant}</code></pre></div><pre><code>{downstreamGrants.join('\n\n')}</code></pre></div>
  </section>;
}

const erdTables = [
  ['products', 'PRODUCTS', 28, 44, ['PK product_id', 'UQ sku', 'JSON attributes'], 100],
  ['batches', 'BATCHES', 230, 44, ['PK batch_id', 'FK product_id', 'recall_status'], 120],
  ['investigations', 'RECALL_INVESTIGATIONS', 432, 20, ['PK case_id', 'FK batch_id', 'JSON case_data'], 101],
  ['batchComponents', 'BATCH_COMPONENTS', 230, 188, ['PK batch_component_id', 'FK batch_id', 'FK component_batch_id'], 300],
  ['componentBatches', 'COMPONENT_BATCHES', 442, 188, ['PK component_batch_id', 'FK component_id', 'FK supplier_site_id'], 300],
  ['components', 'COMPONENTS', 654, 70, ['PK component_id', 'UQ component_code', 'JSON attributes'], 120],
  ['supplierSites', 'SUPPLIER_SITES', 654, 266, ['PK supplier_site_id', 'FK supplier_id', 'UQ site_code'], 150],
  ['suppliers', 'SUPPLIERS', 866, 266, ['PK supplier_id', 'supplier_name', 'tier_no'], 120],
  ['componentSiteEdges', 'COMPONENT_BATCH_SITE_EDGES', 442, 370, ['PK edge_id', 'FK component_batch_id', 'FK supplier_site_id'], 300],
  ['componentTypeEdges', 'COMPONENT_BATCH_COMPONENT_EDGES', 654, 400, ['PK edge_id', 'FK component_batch_id', 'FK component_id'], 300],
  ['supplierSiteEdges', 'SUPPLIER_SITE_EDGES', 866, 400, ['PK edge_id', 'FK supplier_site_id', 'FK supplier_id'], 150],
  ['shipments', 'SHIPMENTS', 28, 510, ['PK shipment_id', 'FK batch_id', 'shipped_on'], 200],
  ['batchShipments', 'BATCH_SHIPMENTS', 230, 510, ['PK batch_shipment_id', 'FK batch_id', 'FK shipment_id'], 200],
  ['shipmentItems', 'SHIPMENT_ITEMS', 442, 510, ['PK shipment_item_id', 'FK shipment_id', 'FK store_id'], 205],
  ['stores', 'STORES', 654, 510, ['PK store_id', 'UQ store_code', 'region_code'], 150],
  ['customers', 'CUSTOMERS', 866, 510, ['PK customer_id', 'FK home_store_id', 'email'], 1001],
  ['purchases', 'PURCHASES', 1078, 510, ['PK purchase_id', 'FK customer_id', 'FK batch_id'], 1001],
  ['complaints', 'COMPLAINTS', 866, 664, ['PK complaint_id', 'FK customer_id', 'FK reported_batch'], 310],
  ['complaintChunks', 'COMPLAINT_CHUNKS', 1078, 664, ['PK chunk_id', 'FK complaint_id', 'chunk_text'], 310],
  ['actions', 'RECALL_ACTIONS', 28, 684, ['PK action_id', 'UQ action_code', 'priority_no'], 100],
  ['centers', 'RESPONSE_CENTERS', 230, 684, ['PK center_id', 'center_name', 'longitude / latitude'], 120],
  ['queries', 'RECALL_QUERIES', 442, 684, ['PK query_key', 'search_text'], 100],
];

const erdJoins = [
  ['products', 'batches'], ['batches', 'investigations'], ['batches', 'batchComponents'], ['batchComponents', 'componentBatches'],
  ['componentBatches', 'components'], ['componentBatches', 'supplierSites'], ['supplierSites', 'suppliers'], ['componentBatches', 'componentSiteEdges'],
  ['componentSiteEdges', 'supplierSites'], ['componentBatches', 'componentTypeEdges'], ['componentTypeEdges', 'components'], ['supplierSites', 'supplierSiteEdges'],
  ['supplierSiteEdges', 'suppliers'], ['batches', 'shipments'], ['batches', 'batchShipments'], ['batchShipments', 'shipments'],
  ['shipments', 'shipmentItems'], ['shipmentItems', 'stores'], ['stores', 'customers'], ['customers', 'purchases'], ['batches', 'purchases'],
  ['customers', 'complaints'], ['batches', 'complaints'], ['complaints', 'complaintChunks']
];

function SchemaDiagram() {
  const byId = new Map(erdTables.map(([id, , x, y]) => [id, { x, y }]));
  return <section className="panel schema-panel" role="tabpanel" aria-label="Recall database relationship diagram">
    <div className="panel-header"><div><p className="eyebrow">Oracle Database schema</p><h2>Recall data model and joins</h2><TechTags items={['JSON', 'Spatial', 'Graph', 'Vector', 'DDS']} /></div><span className="panel-count"><Table2 size={14} /> {erdTables.length} tables</span></div>
    <div className="schema-intro"><span><i /> Primary key</span><span><i /> Foreign-key join</span><span><i /> JSON document</span><small>Header badges show deterministic seed row counts. Connectors show the declared foreign-key paths.</small></div>
    <div className="schema-scroll"><div className="schema-canvas">
      <svg className="schema-lines" viewBox="0 0 1270 790" aria-hidden="true">{erdJoins.map(([from, to]) => { const source = byId.get(from); const target = byId.get(to); return <line key={`${from}-${to}`} x1={source.x + 80} y1={source.y + 42} x2={target.x + 80} y2={target.y + 42} />; })}</svg>
      {erdTables.map(([id, name, x, y, fields, rowCount]) => <article className="schema-table" key={id} style={{ left: x, top: y }}><h3><span>{name}</span><b>{formatNumber(rowCount)} total rows</b></h3><ul>{fields.map((field) => <li key={field} className={field.startsWith('PK') ? 'key' : field.startsWith('FK') ? 'foreign-key' : field.includes('JSON') ? 'json-field' : ''}>{field}</li>)}</ul></article>)}
    </div></div>
  </section>;
}

function App() {
  const [identity, setIdentity] = useState(null);
  const [bundle, setBundle] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [activeWorkspaceTab, setActiveWorkspaceTab] = useState('overview');
  const [selectedVectorEvidence, setSelectedVectorEvidence] = useState(null);

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
    setSelectedVectorEvidence(null);
  }

  function openVectorEvidence(record) {
    setSelectedVectorEvidence(record);
    setActiveWorkspaceTab('product');
  }

  if (!identity && !loading) return <Login onLogin={(nextIdentity) => { setIdentity(nextIdentity); loadBundle(); }} />;
  if (loading || !bundle) return <div className="loading-shell"><div className="loading-spinner" /><p>Opening secured recall workspace...</p></div>;
  if (error) return <div className="loading-shell"><CircleAlert size={28} /><h2>Unable to load the recall workspace</h2><p>{error}</p><button className="primary-button" onClick={logout}>Return to sign in</button></div>;

  const context = bundle.context || {};
  const product = bundle.product || {};
  const workspaceTabs = [
    { id: 'overview', label: 'Overview', icon: Activity },
    { id: 'dds', label: 'Deep Data Security', icon: ShieldCheck },
    { id: 'map', label: 'Store Map', icon: MapPinned },
    { id: 'product', label: 'JSON Duality', icon: Braces },
    { id: 'evidence', label: 'Evidence Vectors', icon: FileSearch },
    { id: 'graph', label: 'Property Graph', icon: GitGraph },
    { id: 'chat', label: 'Agent Chat', icon: MessageCircle },
    { id: 'campaign', label: 'Recall Campaign', icon: Megaphone }
  ];
  const switchWorkspaceTab = (tab) => setActiveWorkspaceTab(tab);
  return (
    <main className="app-shell">
      <aside className="sidebar">
        <div className="brand-mark sidebar-brand oracle-ai-brand"><img src="/oracle-ai-database-26ai.png" alt="Oracle AI Database" /><b>26ai</b></div>
        <div className="sidebar-title"><span className="pulse-dot" /> Recall operations</div>
        <nav className="side-nav" aria-label="Recall workspace sections">
          {workspaceTabs.map(({ id, label, icon: Icon }) => <a key={id} className={activeWorkspaceTab === id ? 'active' : ''} href={`#${id}`} onClick={() => switchWorkspaceTab(id)}><Icon size={17} /> {label}</a>)}
        </nav>
        <div className="sidebar-bottom"><div className="converged-badge"><span><Boxes size={17} /></span><div><b>Converged evidence</b><small>JSON · Spatial · Graph · Vector · Agent</small></div></div><div className="security-badge"><ShieldCheck size={15} /><span>Deep Data Security active</span></div></div>
      </aside>

      <section className="workspace" id="overview">
        <header className="topbar"><div className="mobile-title"><span className="pulse-dot" /> Recall operations</div><div className="topbar-actions"><div className="batch-selector"><span>Active batch</span><b>{context.batchId || 'B-482'}</b><ChevronRight size={15} /></div><div className="identity-chip"><div className="identity-avatar">{identity.username?.slice(0, 2)}</div><div><b>{identity.roleLabel}</b><span>{identity.username}</span></div><button className="logout-button" type="button" onClick={logout} title="Sign out" aria-label="Sign out"><LogOut size={15} /><span>Sign out</span></button></div></div></header>
        <div className="content">
          <section className="page-heading"><div><p className="eyebrow">Live incident · {product.recallStatus || 'INVESTIGATING'}</p><h1>Recall command center</h1><p>Role-aware evidence for <b>{product.product || 'HeatPro Countertop Cooker'}</b> · {context.batchId || 'B-482'}</p></div><div className="heading-actions"><button className="icon-button" onClick={loadBundle} title="Refresh secured evidence" aria-label="Refresh secured evidence"><Activity size={17} /></button></div></section>
          {activeWorkspaceTab === 'overview' && <><section className="stats-grid"><StatCard icon={Store} label="Visible stores" value={formatNumber(context.affectedStoreCount)} detail="within your role scope" tone="teal" /><StatCard icon={PackageSearch} label="Units in scope" value={formatNumber(context.unitsSent)} detail="shipped in batch B-482" tone="orange" /><StatCard icon={Users} label="Exposed customers" value={formatNumber(context.customerExposureCount)} detail="authorized count only" tone="blue" /><StatCard icon={FileSearch} label="Priority complaints" value={formatNumber(context.semanticComplaints?.length)} detail="vector-ranked evidence" tone="red" /></section><DdsPersonaPanel identity={identity} /></>}
          <nav className="workspace-tabs" role="tablist" aria-label="Recall workspace pages">
            {workspaceTabs.map(({ id, label, icon: Icon }) => <button key={id} type="button" role="tab" aria-selected={activeWorkspaceTab === id} className={activeWorkspaceTab === id ? 'active' : ''} onClick={() => switchWorkspaceTab(id)}><Icon size={16} /> {label}</button>)}
          </nav>
          {activeWorkspaceTab === 'overview' && <SchemaDiagram />}
          {activeWorkspaceTab === 'dds' && <section className="tab-page" role="tabpanel" aria-label="Deep Data Security"><DeepDataSecurityPanel identity={identity} /></section>}
          {activeWorkspaceTab === 'map' && <section className="main-grid tab-page" role="tabpanel" aria-label="Store Map"><MapPanel stores={bundle.stores} /><RegionBars stores={bundle.stores} /><StoreDataTable stores={bundle.stores} /></section>}
          {activeWorkspaceTab === 'product' && <section className="tab-page product-record-page" role="tabpanel" aria-label="Product Record JSON"><ProductPanel product={product} selectedEvidence={selectedVectorEvidence} onClearSelectedEvidence={() => setSelectedVectorEvidence(null)} /></section>}
          {activeWorkspaceTab === 'evidence' && <section className="tab-page evidence-page" role="tabpanel" aria-label="Evidence Vectors"><ComplaintPanel batchId={context.batchId || 'B-482'} onSelectEvidence={openVectorEvidence} /></section>}
          {activeWorkspaceTab === 'graph' && <section className="tab-page" role="tabpanel" aria-label="Property Graph"><GraphPanel graph={bundle.graph} /></section>}
          {activeWorkspaceTab === 'campaign' && <section className="tab-page" role="tabpanel" aria-label="Recall Response Campaign"><CampaignPanel batchId={context.batchId || 'B-482'} identity={identity} product={product} /></section>}
          {activeWorkspaceTab === 'chat' && <section className="tab-page" role="tabpanel" aria-label="Agent Chat"><ChatPanel batchId={context.batchId || 'B-482'} /></section>}
        </div>
      </section>
    </main>
  );
}

export default App;
