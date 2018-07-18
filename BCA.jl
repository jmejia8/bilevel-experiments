import Metaheuristics: eca


threshold = 1e-3

function BCA(F::Function, f::Function, upper_D, lower_D, upper_bounds, lower_bounds)
    K = 7
    N = K*lower_D

    Fobj(x) = begin
        # y ∈ arg min { f(x, z) : z ∈ Y }
        y, fval = eca( z-> f(x, z), lower_D;
                                    limits=lower_bounds,
                                    K = K, N = N,
                                    showResults=false,
                                    p_bin = 0,
                                    canResizePop=true,   
                                    max_evals=500lower_D)

        # return upper level value
        return F(x, y)
    end

    # optimize
    x, Fv = eca(Fobj, upper_D;
                    limits=upper_bounds,
                    N = 7*upper_D,
                    showResults=false,
                    p_bin = 0,
                    max_evals=500upper_D,
                    saveConvergence="output/leader$(current_f)_r$(current_r).csv",
                    saveLast="output/leader$(current_f)_last_r$(current_r).csv",
                    showIter=false)

    y, fv = eca( z-> f(x, z), lower_D;
                            showResults=false,
                            p_bin = 0,
                            canResizePop=true,
                            limits=lower_bounds,
                            max_evals=500lower_D)

    return x, F(x,y), f(x,y)
end
