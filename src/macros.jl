#=

  #define STINGER_GENERIC_FORALL_EDGES_OF_VTX_BEGIN(STINGER_,VTX_,EDGE_FILTER_,EB_FILTER_,PARALLEL_)\
    do {                                                                                                    \
    stinger_vertices_t * vertices = (stinger_vertices_t *)((S)->storage); \
    stinger_physmap_t * physmap = (stinger_physmap_t *)((S)->storage + (S)->physmap_start); \
    stinger_names_t * etype_names = (stinger_names_t *)((S)->storage + (S)->etype_names_start); \
    stinger_names_t * vtype_names = (stinger_names_t *)((S)->storage + (S)->vtype_names_start); \

    uint8_t * _ETA = ((S)->storage + (S)->ETA_start); \
    struct stinger_ebpool * ebpool = (struct stinger_ebpool *)((S)->storage + (S)->ebpool_start);                                            \
    struct stinger_eb * ebpool_priv = ebpool->ebpool;
    struct stinger_eb *  current_eb__ = ebpool_priv + stinger_vertex_edges_get(vertices, VTX_);           \

    while(current_eb__ != ebpool_priv) {                                                                  \
        int64_t source__ = current_eb__->vertexID;                                                          \
        int64_t type__ = current_eb__->etype;                                                               \
        EB_FILTER_ {                                                                                        \
          PARALLEL_                                                                                         \
          for(uint64_t i__ = 0; i__ < stinger_eb_high(current_eb__); i__++) {                               \
            if(!stinger_eb_is_blank(current_eb__, i__)) {                                                   \
              struct stinger_edge * current_edge__ = current_eb__->edges + i__;                             \
              EDGE_FILTER_ {


    #define STINGER_GENERIC_FORALL_EDGES_OF_VTX_END()         \
                } /* end EDGE_FILTER_ */                      \
              } /* end if eb blank */                         \
            } /* end for edges in eb */                       \
          } /* end EB_FILTER_ */                              \
        current_eb__ = ebpool_priv + (current_eb__->next);  \
      } /* end while not last edge */                       \
    } while (0)

    struct stinger_ebpool {
      uint64_t ebpool_tail;
      uint8_t is_shared;
      struct stinger_eb ebpool[0];
    };


    struct stinger_vertex
    {
        vtype_t     type;	  /**< Vertex type */
        vweight_t   weight;     /**< Vertex weight */
        vdegree_t   inDegree;   /**< In-degree of the vertex */
        vdegree_t   outDegree;  /**< Out-degree of the vertex */
        vdegree_t   degree; /**< Degree when counting both in an out edges */
        adjacency_t edges;	  /**< Reference to the adjacency structure for this vertex */
        #if defined(STINGER_VERTEX_KEY_VALUE_STORE)
            key_value_store_t attributes;
            #endif
    };

    struct stinger_vertices
    {
        int64_t	    max_vertices;
        stinger_vertex_t  vertices[0];
    };

   struct stinger_eb
 {
   eb_index_t next;      /**< Pointer to the next edge block */
   int64_t etype;        /**< Edge type of this edge block */
   int64_t vertexID;     /**< Source vertex ID associated with this edge block */
   int64_t numEdges;     /**< Number of valid edges in the block */
   int64_t high;         /**< High water mark */
   int64_t smallStamp;       /**< Smallest timestamp in the block */
   int64_t largeStamp;       /**< Largest timestamp in the block */
   int64_t cache_pad;        /**< Does not do anything -- for performance reasons only */
   struct stinger_edge edges[STINGER_EDGEBLOCKSIZE]; /**< Array of edges */
};

78 struct stinger_edge
79 {
80   int64_t neighbor; /**< The adjacent vertex ID.  The 2 Most significant bits below the sign bit store the direction of the edge     */
81   int64_t weight;   /**< The integer edge weight */
82   int64_t timeFirst;    /**< First time stamp for this edge */
83   int64_t timeRecent;   /**< Recent time stamp for this edge */
84 };
=#

export foralledges, edgeparse, StingerEdge

type StingerVertex
    vtype::Int64
    weight::Int64
    indegree::Int64
    outdegree::Int64
    degree::Int64
    edges::Int64
end

const NUMEDGEBLOCKS = 14

type StingerEdge
    neighbor::Int64
    weight::Int64
    timefirst::Int64
    timerecent::Int64
end

type StingerEdgeBlock
    next::UInt64
    etype::Int64
    vertexid::Int64
    numedges::Int64
    high::Int64
    smallstamp::Int64
    largestamp::Int64
    cache_pad::Int64
end

function edgeparse(edge::StingerEdge)
    direction = edge.neighbor >> 61 #The first 2 bits denote the direction, 2 - out, 1 - in, 3 - both
    neighbor = ~(7 << 61) & edge.neighbor
    return direction, neighbor
end

function stinger_vertex_get(s::Stinger, v::Int64)
    vertices = convert(Ptr{StingerVertex}, storageptr(s) + sizeof(Int64)) #Read the StingerVertex array
    vertex = unsafe_load(vertices, v+1)
    vertex
end

function stinger_vertex_edges_get(s::Stinger, v::Int64)
    vertex = stinger_vertex_get(s,v)
    vertex.edges
end

function foralledges(f::Function, s::Stinger, v::Int64)
    storage = storageptr(s)
    ebpool = storage + s[ebpool_start] * (sizeof(UInt8))
    ebpool_priv_ptr = ebpool + sizeof(UInt64) * 2 #gcc seems to pad this
    current_eb_ptr = ebpool_priv_ptr + stinger_vertex_edges_get(s, v)*(sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
    while current_eb_ptr != ebpool_priv_ptr
        current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))
        src = current_eb.vertexid
        etype = current_eb.etype
        for i=1:current_eb.high
            current_edge = unsafe_load(convert(Ptr{StingerEdge}, current_eb_ptr+sizeof(StingerEdgeBlock)), i)
            f(current_edge, src, etype)
        end
        current_eb_ptr = ebpool_priv_ptr + current_eb.next;
    end
end
