/*
 * Copyright (C) 2013, 2026, Oracle and/or its affiliates.
 * ORACLE PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */
import type { Map, SourceSpecification } from 'maplibre-gl';

type Optional<T> = T | undefined;

type Nullable<T> = T | null;

type TypedMap<T> = Record<string, T>;

type NestedPartial<T> = {
  [P in keyof T]?: NestedPartial<T[P]>;
};

type NestedFlags<T> = {
  [P in keyof T]?: T[P] extends object ? false | NestedFlags<T[P]> : T[P];
};

type NestedExpressions<T> = {
  [P in keyof T]: T[P] extends Nullable<Optional<object>> ? NestedExpressions<T[P]> : T[P] | string;
};

type Shortcuts<T> = {
  [P in keyof T]: T[P] extends Nullable<Optional<object>> ? string | T[P] : T[P];
};

type PartialStyle<T> = Shortcuts<NestedExpressions<NestedPartial<T>>>;

type NestedPartialStyle<T> = Omit<PartialStyle<T>, 'children'> & {
  children?: Nullable<TypedMap<PartialStyle<_VertexStyle> & Classable>>;
};

type NonEmptyArray<T> = [T, ...T[]];

type AtLeastOneRequired<T, U = { [K in keyof T]: Pick<T, K> }> = Partial<T> & U[keyof U];

type Id = string | number;

type LegendType = 'vertex' | 'edge';

type InterpolationType = 'sizes' | 'colors';

export type TriangleDirection = 'up' | 'down' | 'left' | 'right';

export interface CircleVertexShape {
  type: 'circle';
}

export interface EllipseVertexShape {
  type: 'ellipse';
  widthHeightRatio?: number;
}

export interface SquareVertexShape {
  type: 'square';
}

export interface RectangleVertexShape {
  type: 'rectangle';
  widthHeightRatio?: number;
}

export interface RoundedRectangleVertexShape {
  type: 'roundedRectangle';
  widthHeightRatio?: number;
  cornerRadiusRatio?: number;
}

export interface TriangleVertexShape {
  type: 'triangle';
  direction?: TriangleDirection;
}

export interface DiamondVertexShape {
  type: 'diamond';
}

export interface PentagonVertexShape {
  type: 'pentagon';
}

export interface HexagonVertexShape {
  type: 'hexagon';
}

export interface OctagonVertexShape {
  type: 'octagon';
}

export type VertexShape =
  | CircleVertexShape
  | EllipseVertexShape
  | SquareVertexShape
  | RectangleVertexShape
  | RoundedRectangleVertexShape
  | TriangleVertexShape
  | DiamondVertexShape
  | PentagonVertexShape
  | HexagonVertexShape
  | OctagonVertexShape;

export type ShapeType = VertexShape['type'];

export interface TypedArrayMap<TValue = any> {
  [key: string]: TValue;
}

interface Classable {
  classes?: string[];
}

interface Entity extends Classable {
  id: Id;
  properties?: EntityProperties;
  style?: VertexStyle | EdgeStyle;
  defaultColor?: string;
  labels?: string[];
}

export interface Vertex extends Entity {}

export interface Edge extends Entity {
  source: Id;
  target: Id;
  /** Indicates an artificial edge that represents an indirect path between visible vertices. */
  isReachab?: boolean;
  /** Lists hidden vertex ids that lie on the underlying indirect path. */
  via?: Id[];
  /** Id of the original edge that supplied the base styling for this indirect edge. */
  seedEdgeId?: Id;
}

interface Fetchable {
  numResults?: number;
  isLastResultSet?: boolean;
}

export interface Graph extends Fetchable {
  vertices: Vertex[];
  edges: Edge[];
  vertexIdColumnNames?: string[];
  edgeIdColumnNames?: string[];
}

export type RelationshipType = 'descendant' | 'ancestor' | 'sibling';
export type VertexSearchResult = Record<Id, Vertex>;
export type EdgesSearchResult = Record<Id, Edge>;
export type DefaultProps = Record<Id, string | number>;

export type GetActiveElementParams = {
  activeElementIndex: number;
  vertices: Vertex[];
  edges: Edge[];
  elementMode: TraverseMode;
  selection: Entity[];
  searchKeyword: string | undefined;
};

export interface SearchResult {
  vertices?: VertexSearchResult;
  edges?: EdgesSearchResult;
  defaultProps?: DefaultProps;
}

export type FeatureFlags =
  | false
  | NestedFlags<{
      exploration: {
        expand: boolean;
        focus: boolean;
        group: boolean;
        ungroup: boolean;
        drop: boolean;
        undo: boolean;
        redo: boolean;
        reset: boolean;
      };
      modes: {
        interaction: boolean;
        fitToScreen: boolean;
        sticky: boolean;
        evolution: boolean;
        reachabilityPaths: boolean;
      };
      displaySizeControl: boolean;
    }>;

type LayoutType =
  | 'circle'
  | 'concentric'
  | 'force'
  | 'grid'
  | 'hierarchical'
  | 'preset'
  | 'radial'
  | 'random'
  | 'geographical';

interface BaseLayoutSettings {
  type: LayoutType;
}

interface SpacingLayoutSettings {
  spacing: number;
}

interface CircleLayoutSettings extends BaseLayoutSettings, SpacingLayoutSettings {
  type: 'circle';
}

interface ClusterOptions {
  clusterBy?: string;
  hideUnclusteredVertices?: boolean;
}

interface ConcentricLayoutSettings extends BaseLayoutSettings, SpacingLayoutSettings {
  type: 'concentric';
}

interface ForceLayoutSettings extends BaseLayoutSettings, SpacingLayoutSettings {
  type: 'force';
  alphaDecay: number;
  velocityDecay: number;
  edgeDistance: number;
  vertexCharge: number;
  clusterEnabled: boolean;
  clusterOptions?: ClusterOptions;
}

interface GridLayoutSettings extends BaseLayoutSettings, SpacingLayoutSettings {
  type: 'grid';
  rows?: number;
  columns?: number;
}

type HierarchicalRankDirection = 'UL' | 'UR' | 'DL' | 'DR' | 'TB' | 'BT' | 'LR' | 'RL';

type HierarchicalRanker = 'network-simplex' | 'tight-tree' | 'longest-path';

interface HierarchicalLayoutSettings extends BaseLayoutSettings {
  type: 'hierarchical';
  rankDirection: HierarchicalRankDirection;
  ranker: HierarchicalRanker;
  vertexSeparation?: number;
  edgeSeparation?: number;
  rankSeparation?: number;
}

interface PresetLayoutSettings extends BaseLayoutSettings {
  type: 'preset';
  x: string;
  y: string;
}

interface RadialLayoutSettings extends BaseLayoutSettings, SpacingLayoutSettings {
  type: 'radial';
}

interface RandomLayoutSettings extends BaseLayoutSettings {
  type: 'random';
}

interface GeographicalLayoutSettings extends BaseLayoutSettings {
  type: 'geographical';
  longitude: string;
  latitude: string;
  appId?: string;
  mapType?: MapType;
  showInfo?: boolean;
  showNavigation?: boolean;
  layers?: string;
  sources?: string;
  markers?: MapMarker[];
}

export type Sources = Record<string, SourceSpecification>;

export type MapType = 'osm_positron' | 'osm_bright' | 'osm_darkmatter' | 'world_map_mb' | 'custom_type';

interface MapMarker {
  longitude: number;
  latitude: number;
  content?: string;
}

export type SliderValues = {
  min: number;
  max: number;
  step: number;
  scale: number;
};

export type SliderSettings = { [key in FilterComponent]: SliderValues };

export type HighlightTargets = {
  [key in FilterComponent]: {
    id: ApplyTarget;
    type: FilterComponent;
  }[];
};

export type HighlightType = 'styling' | 'visibility' | 'aggregation';

export type HighlightStylingType =
  | 'size'
  | 'color'
  | 'label'
  | 'icon'
  | 'image'
  | 'edgeStyle'
  | 'animationsVertex'
  | 'animationsEdge';

export type FilterOperator = '<' | '<=' | '>' | '>=' | '=' | '!=' | '~' | 'CONTAINS' | 'CONTAINS_REGEX';

export type HighlightAttributesType = {
  type: HighlightStylingType;
};

export type HighlightAttributes = {
  [key in ApplyTarget]: HighlightAttributesType[];
};

export type FilterTarget = {
  id: FilterComponent;
};

export type ApplyTarget = 'vertex' | 'source' | 'target' | 'edge' | 'ingoing' | 'outgoing';

export type FilterComponent = 'vertex' | 'edge';

export type ElementPropertyValue = string | number | string[];

export interface ElementProperty<T> {
  property: string;
  value: T;
}

export interface BasicCondition extends ElementProperty<string | string[]> {
  operator: FilterOperator;
}

export interface RuleCondition {
  rule: string;
}

export type ConditionsOperator = 'and' | 'or';

export interface Conditions<T extends RuleCondition | BasicCondition> {
  conditions: T[];
  operator?: ConditionsOperator;
}

export type interpolationFunction = (t: number) => string | number;

export interface FilterInterpolation {
  property: string;
  min?: number;
  max?: number;
}

export declare type FilterProperties = {
  colors?: string[];
  classes?: string[];
  sizes?: number[];
  icons?: string[];
  iconColors?: string[];
  image?: string[];
  label?: string[];
  style?: string[];
  animations?: GraphAnimation[][];
  legendTitle?: string[];
  legendDescription?: string[];
};

export interface FromTemplate {
  _fromTemplate?: boolean;
  _id?: number | string;
}

export type AggregationType = 'average' | 'min' | 'max' | 'sum' | 'count' | 'distinctCount';

export interface PropertyAggregation {
  enabled?: boolean;
  property?: string;
  type: AggregationType;
}

export type StyleAction = 'visibilityToggle' | 'stylingToggle' | 'reorder';

export type OverlayIndicatorIcon = 'pin' | 'bookmark';

export interface RuleBasedStyleSetting extends FromTemplate {
  originalId?: Id;
  stylingEnabled?: boolean;
  visibilityEnabled?: boolean;
  legendDisplayed?: boolean;
  conditions?: Conditions<BasicCondition | RuleCondition>;
  component: FilterComponent;
  target: ApplyTarget;
  properties?: FilterProperties;
  style?: Partial<VertexStyle> | Partial<EdgeStyle>;
  interpolation?: FilterInterpolation;
  filterReferenceIds?: number[];
  legendTitle?: string;
  legendDescription?: string;
  modifierStyles?: TypedMap<VertexStyle | EdgeStyle>;
  animations?: GraphAnimation[][];
  isDefaultRule?: boolean;
  overlayIndicator?: OverlayIndicatorIcon;
}

export interface LegendEntry extends RuleBasedStyleSetting {
  legendTitle?: string[];
  legendEntryVisible: boolean;
  style: Partial<VertexStyle> | Partial<EdgeStyle>;
  filteredNodes: Vertex[] | Edge[];
  toApplyStyle?: Partial<VertexStyle> | Partial<EdgeStyle>;
}

// NOTE: For smart group/expand

export interface ExpandCondition extends BasicCondition {
  component: FilterComponent;
}
export type RuleBasedExplorerType = 'expand' | 'group';

export interface RuleBasedExplorer extends FromTemplate {
  readonly type: RuleBasedExplorerType;
  name: string;
}

export interface RuleBasedGroup extends RuleBasedExplorer {
  readonly type: 'group';
  applyOnLoad: boolean;
  enabled: boolean;
  component: 'vertex' | 'edge';
  groupBy?: string;
  conditions: Conditions<ExpandCondition>;
  aggregations?: PropertyAggregation[];
}

export interface RuleBasedExpand extends RuleBasedExplorer {
  readonly type: 'expand';
  numberOfHops: Optional<number>;
  navigation: Conditions<ExpandCondition>;
  destination: Conditions<ExpandCondition>;
}

// @Deprecated since version 26.2, use RuleBasedExplorerType instead
export type SmartExplorerType = 'expand' | 'group';

// @Deprecated since version 26.2, use RuleBasedExplorer instead
export interface SmartExplorer extends FromTemplate {
  readonly type: SmartExplorerType;
  name: string;
}

// @Deprecated since version 26.2, use RuleBasedExpand instead
export interface SmartExpand extends SmartExplorer {
  readonly type: 'expand';
  numberOfHops: Optional<number>;
  navigation: Conditions<ExpandCondition>;
  destination: Conditions<ExpandCondition>;
}

// @Deprecated since version 26.2, use RuleBasedGroup instead
export interface SmartGroup extends SmartExplorer {
  readonly type: 'group';
  automatic: boolean;
  enabled: boolean;
  groupBy?: string;
  conditions: Conditions<ExpandCondition>;
}

type LayoutSettings =
  | CircleLayoutSettings
  | ConcentricLayoutSettings
  | ForceLayoutSettings
  | GridLayoutSettings
  | HierarchicalLayoutSettings
  | PresetLayoutSettings
  | RadialLayoutSettings
  | RandomLayoutSettings
  | GeographicalLayoutSettings;

interface EvolutionEntity {
  start: string;
  end?: string;
}

export type EvolutionUnit = 'second' | 'minute' | 'hour' | 'day' | 'week' | 'month' | 'year';

interface Evolution {
  height: number;
  chart: 'bar' | 'line';
  granularity: number;
  unit?: EvolutionUnit;
  vertex?: EvolutionEntity;
  edge?: EvolutionEntity;
  exclude: {
    values: (string | number)[];
    show: boolean;
  };
  playback: {
    step: number;
    timeout: number;
  };
  preservePositions?: boolean;
  axis?: 'vertices' | 'edges' | 'both';
  labelFormat?: string;
}

interface GraphAnimation {
  id?: string;
  duration: number;
  timingFunction: string;
  direction?: string;
  keyFrames: KeyFrame[];
  iterationCount?: number;
}

interface CustomTheme {
  backgroundColor?: string;
  textColor?: string;
}

export type Theme = 'light' | 'dark';

export type EdgeMarker = 'arrow' | 'none';

export type ExpandedState = 'expanded' | 'collapsed';

type DefaultSettings = {
  interactionActive: Optional<Boolean>;
  fitToScreenActive: Optional<Boolean>;
  stickyActive: Optional<Boolean>;
  evolutionActive: Optional<Boolean>;
  reachabilityPathsActive: Optional<Boolean>;
};

interface _Settings {
  // @Deprecated since version 25.3, use displaySizeOnLoad instead
  pageSize?: number;
  formatNumbers: boolean;
  searchEnabled: boolean;
  groupEdges: boolean;
  escapeHtml: boolean;
  layout: LayoutType | Partial<LayoutSettings>;
  evolution: NestedPartial<Shortcuts<Evolution>>;
  legendWidth: number;
  numberOfHops: number;
  maxNumberOfHops: number;
  ruleBasedExpands: RuleBasedExpand[];
  ruleBasedGroups: RuleBasedGroup[];
  smartExpands: SmartExpand[]; // @Deprecated since version 26.2, use ruleBasedExpands instead
  smartGroups: SmartGroup[]; // @Deprecated since version 26.2, use ruleBasedGroups instead
  selectedRuleBasedExpand: Nullable<number>;
  selectedRuleBasedGroup: Nullable<number>;
  selectedSmartExpand: Nullable<number>; // @Deprecated since version 26.2, use selectedRuleBasedExpand instead
  selectedSmartGroup: Nullable<number>; // @Deprecated since version 26.2, use selectedRuleBasedGroup instead
  sizeMode: SizeMode;
  searchValue: string | undefined;
  theme: Theme;
  edgeMarker: EdgeMarker;
  charLimit: number;
  showTitle: boolean;
  vertexLabelProperty: Nullable<string>;
  edgeLabelProperty: Nullable<string>;
  customTheme: CustomTheme;
  tooltipCharLimit: Nullable<number>;
  ruleBasedStyles: RuleBasedStyleSetting[];
  baseStyles: Styles;
  viewMode?: ExpandedState;
  viewLabel?: string;
  legendState?: ExpandedState;
  accessibilityEnabled?: Boolean;
  visibilityToggleMode?: VisibilityToggleMode;
  defaults: Partial<DefaultSettings>;
  displaySizeOnLoad?: number;
  defaultLegendEnabled?: boolean;
}
export type VisibilityToggleMode = 'hideWhenAnyUnchecked' | 'hideWhenAllUnchecked';
export type SizeMode = 'compact' | 'normal';
export type ControlSizeMode = SizeMode | 'large';

interface ElementPosition {
  angle?: Nullable<number>;
  position: number;
  d: number;
}

interface FontStyle {
  size: number;
  family: string;
  style: string;
  weight: string;
}

interface LabelStyle extends ElementPosition {
  text: string;
  color?: string;
  maxLength: number;
  font: FontStyle;
  disableBackdrop: boolean;
  resizeParent: boolean;
}

interface Style extends ElementPosition {
  color: string | string[];
  opacity: number;
  filter: string;
  /** @deprecated since version 26.2, use caption instead. Will be removed in a future release. */
  label: Nullable<LabelStyle>;
  caption?: Nullable<LabelStyle>;
  children: Nullable<TypedMap<_VertexStyle & Classable>>;
  legend: Nullable<this & { text: string }>;
}

interface ImageStyle {
  url: string;
  scale: number;
}

interface BorderStyle {
  width: number;
  color: string;
}

interface IconStyle {
  class: string;
  color: string;
}

interface _VertexStyle extends Style {
  size: number;
  image: Nullable<ImageStyle>;
  border: Nullable<BorderStyle>;
  icon: Nullable<IconStyle>;
  relationshipCaption?: Nullable<LabelStyle>;
  shape?: Nullable<ShapeType | VertexShape>;
}

interface _EdgeStyle extends Style {
  width: number;
  dasharray?: string;
}

export interface EdgeWithLayout extends Edge {
  _source: Id;
  _target: Id;
}
export interface ReachabilityPathDescriptor {
  source: Id;
  target: Id;
  via: Id[];
  seedEdgeId: Id;
  hiddenVertexCount: number;
  hiddenVertices: Id[];
  hiddenEdgeCount: number;
  hiddenEdges: Id[];
}

export interface QueueEntry {
  seedEdgeId: Id;
  current: Id;
  via: Id[];
  visited: Set<Id>;
  depth: number;
  hiddenPathEdges: Id[];
}

type EntityEventCallback = (event: Event, id: Optional<string>, entity: Entity) => void;

interface _EntityEventHandlers {
  [eventType: string]: EntityEventCallback | _EntityEventHandlers;
  children?: EntityEventHandlers;
}
interface _AllEventHandlers {
  vertex: EntityEventHandlers;
  edge: EntityEventHandlers;
}

export type Settings = Partial<_Settings>;

export type VertexStyle = NestedPartialStyle<_VertexStyle>;

export type EdgeStyle = NestedPartialStyle<_EdgeStyle>;

export type Styles = TypedMap<VertexStyle | EdgeStyle>;

export type EntityEventHandlers = Optional<_EntityEventHandlers>;

export type AllEventHandlers = Partial<_AllEventHandlers>;

export type FetchMore = (start: number, size: number) => Promise<Graph>;

export type OnManyClick = (
  graphQuery: string,
  vertexIdColumnNames: string[],
  edgeIdColumnNames: string[]
) => Promisable<{ vertexCount: number; edgeCount: number }>;

export type Search = (keyword: string, searchGraph?: Optional<_Graph>) => Promise<SearchResult>;

export type Expand = (
  ids: Id[],
  hops: number,
  action: ExpandActionType,
  templateId?: number | null,
  relationshipType?: RelationshipType
) => Promise<Graph>;

export type Persist = (action: GraphAction) => Promise<void>;

export type UpdateGeoMap = (mapElement: Map) => Promise<void>;

export type UpdateSelectedOption = (option: number | null, tag: SmartExplorerType) => Promise<void>;

export type UpdateEvolution = (enabled: boolean) => Promise<void>;

export type UpdateSearchValue = (value: string) => Promise<void>;

export type UpdateGraphData = (Vertices: Vertex[], edges: Edge[]) => Promise<void>;

export type UpdateRuleBasedStyle = (
  style: RuleBasedStyleSetting | RuleBasedStyleSetting[],
  action?: StyleAction
) => Promise<void>;

export type EditRuleBasedStyle = (style: RuleBasedStyleSetting) => Promise<void>;

/**
 * Saved Conditional Search types
 */
export type SavedSearchId = string;

export interface SavedSearch {
  id?: SavedSearchId;
  name: string;
  selectedLabels: string[];
  // Use unknown to avoid a hard dependency on utils.FilterNode from this declaration file
  filterRoot: unknown;
  createdAt?: string;
  updatedAt?: string;
}

export interface SavedSearchProvider {
  list?: () => Promise<SavedSearch[]>;
  upsert?: (config: SavedSearch) => Promise<SavedSearch | void> | SavedSearch | void;
  remove?: (idOrName: string) => Promise<void> | void;
}

export type SavedSearchAction =
  | { type: 'saved_search/save'; config: SavedSearch }
  | { type: 'saved_search/delete'; idOrName: string }
  | { type: 'saved_search/load'; idOrName: string };

export type FetchActions = () => Promise<GraphAction[]>;

export type GraphActionType = 'drop' | 'expand' | 'focus' | 'group' | 'ungroup' | 'undo' | 'redo' | 'reset';

export type GraphStatus = 'loaded' | 'loading' | 'info' | 'none';

export type ExpandActionType = 'expand' | 'focus';

export interface GraphAction {
  type: GraphActionType;
  vertexIds?: NonEmptyArray<Id>;
  edgeIds?: NonEmptyArray<Id>;
  template?: Nullable<number | string>;
}

export type EmptyAction = Pick<GraphAction, 'type'>;

export type VerticesAction = Pick<GraphAction, 'type' | 'vertexIds'>;

export type VerticesOrEdgesAction = AtLeastOneRequired<Pick<GraphAction, 'vertexIds' | 'edgeIds'>> & EmptyAction;

interface IComponentOptions<Props extends Record<string, any> = Record<string, any>> {
  target: Element | ShadowRoot;
  anchor?: Element;
  props?: Props;
  context?: Map<any, any>;
  hydrate?: boolean;
  intro?: boolean;
  $$inline?: boolean;
}

export interface PropertySchema {
  name: string;
  actualDataType?: string;
  dataType: 'string' | 'boolean' | 'number' | 'date' | 'timestamp';
  limits?: number[];
  mandatory?: boolean;
}

export interface EntityLabelSchema {
  labels: string[];
  properties: PropertySchema[];
}

export interface VertexLabelSchema extends EntityLabelSchema {}

export interface EdgeLabelSchema extends EntityLabelSchema {
  sourceVertexLabels?: string[];
  targetVertexLabels?: string[];
}

export interface GraphSchema {
  vertices: VertexLabelSchema[];
  edges: EdgeLabelSchema[];
}

export type EntityValidationType = 'vertex' | 'edge' | 'schema vertex' | 'schema edge';

export interface EntityValidationError {
  entityType?: EntityValidationType;
  entityId?: string;
  entityLabel?: string[];
  property?: string;
  actualType?: string;
  expectedType?: string;
  message?: string;
}

export interface StyleValidationError extends EntityValidationError {
  errorType: 'CONDITIONS_MISSING' | 'OPERATION_NOT_SUPPORTED';
  operator?: FilterOperator;
}

/* eslint-disable @typescript-eslint/no-unused-vars */

export interface SvelteComponentTyped<
  Props extends Record<string, any> = any,
  Events extends Record<string, any> = any,
  Slots extends Record<string, any> = any
> {
  $set(props?: Partial<Props>): void;
  $on<K extends Extract<keyof Events, string>>(type: K, callback: (e: Events[K]) => void): () => void;
  $destroy(): void;
  [accessor: string]: any;
}

export declare class SvelteComponentTyped<
  Props extends Record<string, any> = any,
  Events extends Record<string, any> = any,
  Slots extends Record<string, any> = any
> {
  constructor(options: IComponentOptions<Props>);
}

export default class extends SvelteComponentTyped<
  Partial<{
    data: Graph;
    settings: Settings;
    schema: GraphSchema;
    schemaSettings: Settings;
    styles: Styles;
    featureFlags: FeatureFlags;
    fetchMore: Optional<FetchMore>;
    expand: Optional<Expand>;
    eventHandlers: AllEventHandlers;
    // @Deprecated since version 26.2, use conditional search instead
    searchValueChanged: Optional<Search>;
    hover: Entity[];
    fetchActions: Optional<FetchActions>;
    persist: Optional<Persist>;
    updateRuleBasedStyle: Optional<UpdateRuleBasedStyle>;
    updateSelectedOption: Optional<UpdateSelectedOption>;
    updateEvolution: Optional<UpdateEvolution>;
    updateGraphData: Optional<UpdateGraphData>;
    updateSearchValue: Optional<UpdateSearchValue>;
    editRuleBasedStyle: Optional<EditRuleBasedStyle>;
    onManyClick: Optional<OnManyClick>;
    savedSearches: SavedSearch[];
    savedSearchProvider: SavedSearchProvider;
  }>
> {}
