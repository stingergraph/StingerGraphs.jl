using StingerWrapper
using Base.Test

s = Stinger(5, 0, [0 for i=1:6], [i%5 for i=1:5], [2 for i=1:5], Int64[], Int64[], -2)
@test insert_edge!(s, 0, 1, 4, 2, 2) == 1
@test remove_edge!(s, 0, 1, 4) == 1
@test consistency_check(s, 5) == true
s[:max_netypes] = 6
@test s[:max_netypes] == 6
