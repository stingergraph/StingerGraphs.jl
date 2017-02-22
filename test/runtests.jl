using StingerWrapper
using Base.Test

include("bfstest.jl")

s = Stinger(5, 0, [0 for i=1:6], [i%5 for i=1:5], [2 for i=1:5], Int64[], Int64[], -2)
@test insert_edge!(s, 0, 1, 5, 2, 2) == 1
@test outdegree(s, 1) == 1
@test getsuccessors(s, 1) == [5]
@test insert_edge!(s, 0, 5, 2, 2, 2) == 1
@test insert_edge!(s, 0, 5, 4, 2, 2) == 1
@test insert_edge!(s, 0, 2, 0, 2, 2) == 1
@test insert_edge!(s, 0, 3, 4, 2, 2) == 1
@test insert_edge!(s, 0, 4, 0, 2, 2) == 1
@test bfs(s, 1, 6) == [2, -1, 5, -2, 5,  1]
@test remove_edge!(s, 0, 1, 5) == 1
@test outdegree(s, 1) == 0
@test consistency_check(s, 100) == true
s[max_netypes] = 6
@test s[max_netypes] == 6

bfsutil(5, 10)
