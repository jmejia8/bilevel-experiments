import Metaheuristics: eca

function BCA(F::Function, f::Function, upper_D, lower_D, upper_bounds, lower_bounds)
    K = 7
    N = 2*K*lower_D

    Fobj(x) = begin
        # y ∈ arg min { f(x, z) : z ∈ Y }
        y, fval = eca( z-> f(x, z), lower_D; K = K, N = N,
                                             showResults=false,
                                             adaptive=true,
                                             canResizePop=true,
                                             limits=lower_bounds,
                                             max_evals=250lower_D)
        # return upper level value
        return F(x, y)# + 10fval
    end

    # optimize
    x, Fv = eca(Fobj, upper_D;
                    limits=upper_bounds,
                    showResults=false,
                    adaptive=true,
                    max_evals=250upper_D,
                    saveConvergence="output/leader$(current_f)_r$(current_r).csv",
                    saveLast="output/leader$(current_f)_last_r$(current_r).csv",
                    showIter=false)

    y, fv = eca( z-> f(x, z), lower_D; showResults=false,
                                             adaptive=true,
                                             canResizePop=false,
                                             limits=lower_bounds,
                                             max_evals=250lower_D)

    return x, F(x,y), f(x,y)
end
