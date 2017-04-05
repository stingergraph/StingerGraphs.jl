function nv(g::StingerLG)
    g.nv
end

#= TODO: How do I find the total number of edges in a Stinger?
# Loop through foralledges?
function ne(g::StingerLG)

end
=#

function vertices(g::StingerLG)
    #Convert to 0 based on all the interface functions.
    1:g.nv
end
