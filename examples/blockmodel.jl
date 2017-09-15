""" blockmodels.jl is an example script demonstrating how to estimate stochastic block models using StingerGraphs.

This code is inspired by the Darpa HIVE graph streaming graph challenge.
The goal is to use a Markov Chain Monte Carlo Method for estimating posterior distribution
of the stochastic block model for streaming graphs.

This is called a streaming graph challenge because the data is changing over time,
but this is not actually why we need a streaming graph data structure. 
The community detection algorithm for this problem is an order of magnitude slower
than the the data structure manipulation. This means that a streaming graph engine
is not necessary fo ingesting the data. Instead we are using a streaming graph engine
to store the internal state of the program, which is a novel application of streaming graph
data structures.

The compute intensive part of this problem is the manipulation of the inter block count matrix M.
Especially in the early stages of the algorithm this matrix is basically a graph where MCMC steps lead to
insertions and deletions which change the sparsity pattern of the matrix M. This a CSR approach does not work.

For later steps of the algorithm a dense storage of M is appropriate as the number of communities is small enough.
"""
module SBM

using StingerGraphs

# A hash based type for accumulating counts in sparse 2d array.
const HashMatrix = Dict{Tuple{Int, Int}, Int}

srand(1)


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


function blockcount(s::Stinger, assignment::AbstractArray{Int})
	m = HashMatrix()
	f(e, i, t) = begin
		d, j = edgeparse(e)
		m[(assignment[i],assignment[j])] += 1
	end
	for i,l in enumerate(assignment)
		foralledges(f, s, i)
	end
	return m
end

function cost(m::HashMatrix)
	# TOOD use the correct entropy formula.
	sum(m-diagm(diag(m)))
end

function propose(g, assigment::AbstractArray{Int}, vertex::Int)
	oldcost = cost(g, assignment)
	costs = Dict{Int, Number}()
	foralledges((e,i,t)->begin
		    d, j = edgeparse(e)
		    a = assignment[i]
		    b = assignment[j]
		    assignment[i] = b
		    if b in keys(costs)
			# todo implement break!
		    else
			newcost = cost(g, assignment)
			#set it back (serial only)
			assignment[i] = k
			costs[b] = newcost
		    end
		    end, g, vertex)
	move = sample(costs)
	return move
end

function sample(d::Dict{Int, T}) where T
	l = length(keys(d))
	x = zeros(T, l)
	for (k,p) in d
		x[k] = p
	end
	return sample(x)
end

s = Stinger()

println("We can create two edge lists and fille in both graphs\n")
# TODO ingest SBM
a = kronecker(8, 16)
nv = maximum(a)

for i in 1:nv
	insert_edge!(s, 0, a[1,i], a[2,i], 0,0)
end

println("The neighbors of vertex 6 in graph s are:")
foralledges(printedge,s,6)


# the model matrix interblock communities
m = Stinger()
# the assignment
b = ones(Int, nv)
println("Do some MCMC sampling")



end	
