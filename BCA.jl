using Metaheuristics

const desired_accu = 1e-4

function accuracy_termination(P::Array)
    sol = Metaheuristics.getBest(P, :minimize)

     return abs(sol.f) < desired_accu

end

function lowerOptimizer(f::Function, x::Array{Float64}, D::Int, bounds)
    K = 7
    N = K*D

    best, Population, t, nevals = eca( z-> f(x, z), D;
                                        limits=bounds,
                                        K = K, N = N,
                                        showResults=false,
                                        p_bin = 0,
                                        p_exploit = 2,
                                        canResizePop=true, 
                                        returnDetails = true,
                                        max_evals=500D)
    return  best, nevals
end

function BCA(F::Function, f::Function, upper_D, lower_D, upper_bounds, lower_bounds)
    K = 7
    N = K*lower_D

    lower_nevals = 0

    Fobj(x) = begin
        # y ∈ arg min { f(x, z) : z ∈ Y }
        best, nevals = lowerOptimizer(f, x, lower_D, lower_bounds)

        lower_nevals += nevals
        y, fval = best.x, best.f

        # return upper level value
        return F(x, y) + fval
    end

    # optimize
    best, Population, t, upper_nevals = eca(Fobj, upper_D;
                    limits=upper_bounds,
                    N = 7*upper_D,
                    showResults=false,
                    p_bin = 0,
                    p_exploit = 2,
                    max_evals=500upper_D,
                    saveConvergence="output/leader$(current_f)_r$(current_r).csv",
                    saveLast="output/leader$(current_f)_last_r$(current_r).csv",
                    termination = accuracy_termination,
                    returnDetails = true,
                    canResizePop=true,
                    showIter=false)

    x, Fv = best.x, best.f

    best_lower, nevals = lowerOptimizer(f, x, lower_D, lower_bounds)
    
    y, fv = best_lower.x, best_lower.f

    lower_nevals += nevals

    return x, F(x, y), fv, upper_nevals+1, lower_nevals
end
