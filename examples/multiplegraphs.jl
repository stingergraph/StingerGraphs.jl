""" multipgraphs.jl is an example script demonstrating how to use multple Stinger graphs in the same julia process.

The stinger library is designed for one graph to exist on a single machine. There is nothing in principle to prevent you
from using multiple Stinger graphs in the same memory space, but do not be surprised if you find bugs in stinger functionality
when used in this mode. Please report them eagerly to the Stingr repository bug tracker on github issues.

"""
module MultiStinger

using StingerGraphs
srand(1)

println("Creating two stingrs s and t\n")
s = Stinger()
t = Stinger()

println("We can create two edge lists and fille in both graphs\n")
a = kronecker(8, 16)
b = kronecker(7, 32)

for i in 1:size(a,2)
	insert_edge!(s, 0, a[1,i], a[2,i], 0,0)
end


for i in 1:size(a,2)
	insert_edge!(t, 0, b[1,i], b[2,i], 0,0)
end

""" printedge(e,i,j) is a helper function for printing neighborhoods"""
function printedge(e,i,j) 
	direction, v = edgeparse(e)
	println("$i, $v")
end

""" indegree(s, src) calculates the in-degree of vertex src"""
function indegree(s::Stinger, src::Int)
	indeg = 0
	foralledges((e,i,t)-> begin
			      direction, v = edgeparse(e)
			      if direction == 1 || direction == 3
			      	indeg += 1
				end
				end, s, src)
	return indeg
end

println("The neighbors of vertex 6 in graph s are:")
foralledges(printedge,s,6)
println("The neighbors of vertex 6 in graph t are:")
foralledges(printedge,t,6)
println("As you can see, we have two different graphs in the same process.")


println("We can now show how to make the second graph as a simple contraction of the firt graph")

t = Stinger()
println("Make each vertex point to the highest degree vertex in its neighborhood")

""" collapseboss!(t, s, vertices) fills t with edges based on collapsing each neighborhood in v to a single edge.
Every vertex points to its highest degree neighbor. the weight is the degree.

Arguments:

- t: the target graph, it should be an empty Stinger
- s: the source graph, a stinger with edges in it.
- vertices: a set of vertices to consider typically 1:nv(s)
"""
function collapseboss!(t::Stinger, s::Stinger, vertices::AbstractArray{Int})
	for i in vertices
		jstar, degmax = 0,0
		foralledges((e, u, t)->begin 
			    direction, v = edgeparse(e)
			    d = indegree(s, v)
			    if d >= degmax
				jstar = v
				degmax = d
			     end
			     if degmax == 0
			     	#println("$i has no nonzero indegree neighbors")
				return i, 1
			     end
			     return jstar, degmax
			     end, s, i)
		insert_edge!(t, 0, i, jstar, degmax, 0)
	end
end
collapseboss!(t,s,1:maximum(a))

println("The degrees in graph s")
for i in 1:maximum(a)
	#foralledges(printedge, s, i)
	indeg = indegree(s, i)
	if indeg > 1
		println("v: $i, outdeg:$(outdegree(s, i)), indeg:$indeg")
	end
end

println("The edges in graph t")
for i in 1:maximum(a)
	#foralledges(printedge, t, i)
	indeg = indegree(t, i)
	if indeg > 1
		println("v: $i, outdeg:$(outdegree(t, i)), indeg:$indeg")
	end
end

println("This algorithm converges in one step to a tree (every vertex has only one neighbor)")

t2 = Stinger()

collapseboss!(t2,t, 1:maximum(a))
for i in 1:maximum(a)
	#foralledges(printedge, t2, i)
	indeg = indegree(t2, i)
	if indeg > 1
		println("v: $i, outdeg:$(outdegree(t2, i)), indeg:$indeg")
	end
end

end
