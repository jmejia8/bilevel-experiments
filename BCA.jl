using Metaheuristics

function BCA(F::Function, f::Function, upper_D, lower_D, upper_bounds, lower_bounds)
    Fobj(x) = begin
        # y ∈ arg min { f(x, z) : z ∈ Y }
        y, fval = eca( z-> f(x, z), lower_D; showResults=false,
                                             limits=lower_bounds,
                                             max_evals=1000lower_D)

        # return upper level value
        return F(x, y)
    end

    # optimize
    eca(Fobj, upper_D;limits=upper_bounds,
                     max_evals=500upper_D,
                     showIter=true)
end