using Metaheuristics

function BCA(F::Function, f::Function, upper_D, lower_D, upper_bounds, lower_bounds)
    Fobj(x) = begin
        # y ∈ arg min { f(x, z) : z ∈ Y }
        y, fval = eca( z-> f(x, z), lower_D; showResults=false,
                                             adaptive=true,
                                             canResizePop=true,
                                             limits=lower_bounds,
                                             max_evals=1000lower_D)

        # return upper level value
        return F(x, y)
    end

    # optimize
    x, F = eca(Fobj, upper_D;
                    limits=upper_bounds,
                    adaptive=true,
                    max_evals=200upper_D,
                    showIter=true)
end