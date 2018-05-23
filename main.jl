using Metaheuristics
using BilevelBenchmark

function genBounds(uBounds, lBounds, d)

    return [repmat(uBounds[:,1], 1, d) repmat(uBounds[:,2], 1, d)],
           [repmat(lBounds[:,1], 1, d) repmat(lBounds[:,2], 1, d)]
end

# configures problem
function getBilevel(fnum::Int = 1)
    D = 2
    d = div(D, 2)

    lower_D = upper_D = D

    if fnum == 1
        ub = [-5 10; -5 10.0]
        lb = [-5 10; -π/2 π/2]
    elseif fnum == 2
        ub = [ -5.0    -5; 10.0  1]
        lb = [ -5.0  0.01; 10.0  e]
    elseif fnum == 4
        ub = [-5.0 10; -1  1]
        lb = [-5.0 10;  0  e]
    elseif fnum == 5
        ub = [-5.0 10; -5.0  10.0]
        lb = [-5.0 10; -5.0  10.0]
    end
    
    upper_bounds, lower_bounds = genBounds( ub', lb', d ) 

    # leader
    F(x::Array{Float64}, y::Array{Float64}) = bilevel_leader(x, y, fnum)

    # follower
    f(x::Array{Float64}, y::Array{Float64}) = bilevel_follower(x, y, fnum)
    
    return f, F, lower_D, upper_D, lower_bounds, upper_bounds
end

function main()
    # x: upper level
    # y: lower level
    fnum = 5

    # problem settings
    f, F, lower_D, upper_D, lower_bounds, upper_bounds = getBilevel(fnum)

    # objective function
    Fobj(x) = begin
        # y ∈ arg min { f(x, z) : z ∈ Y }
        y, fval = eca( z-> f(x, z), lower_D; showResults=false, limits=lower_bounds,max_evals=1000lower_D)

        # return upper level value
        return F(x, y)
    end

    # optimize
    x, f = eca(Fobj, upper_D; limits=upper_bounds, max_evals=500upper_D, showIter=true)

end

main()