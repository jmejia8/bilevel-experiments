using BilevelBenchmark
using CSVanalyzer

include("BCA.jl")

current_f = 0
current_r = 0

function configure()
    !isdir("output") && mkdir("output")
    !isdir("summary") && mkdir("summary")
end

function genBounds(uBounds, lBounds, p, q, r, s)

    return [repmat(uBounds[:,1], 1, p) repmat(uBounds[:,2], 1, r)],
           [repmat(lBounds[:,1], 1, q) repmat(lBounds[:,2], 1, r + s)]
end

# configures problem
function getBilevel(fnum::Int)

    if fnum == 1 || fnum == 3
        ub = [-5 10; -5 10.0]
        lb = [-5 10; -π/2 π/2]
    elseif fnum == 2 || fnum == 7
        ub = [-5 10; -5 1.0]
        lb = [ -5.0  10; 0.0  e]
    elseif fnum == 4
        ub = [-5.0 10; -1  1]
        lb = [-5.0 10;  0  e]
    elseif fnum == 5  || fnum == 6 || fnum == 8
        ub = [-5.0 10; -5.0  10.0]
        lb = [-5.0 10; -5.0  10.0]
    end

    if fnum == 6
        p, q, r, s = 3, 1, 2, 2
    else
        p, q, r, s = 3, 3, 2, 0
    end
    
    upper_D, lower_D = p + r, q + r + s

    upper_bounds, lower_bounds = genBounds( ub', lb', p, q, r, s ) 

    # leader
    F(x::Array{Float64}, y::Array{Float64}) =  SMD_leader(x, y, fnum, p, q, r, s)

    # follower
    f(x::Array{Float64}, y::Array{Float64}) =SMD_follower(x, y, fnum, p, q, r, s)
    
    return f, F, lower_D, upper_D, lower_bounds, upper_bounds
end

function main()
    configure()

    FNUMS =  8
    NRUNS = 31

    Fs = zeros(FNUMS, NRUNS)
    fs = zeros(FNUMS, NRUNS)

    println("f \t run \t F \t f")
    for fnum = 1:FNUMS
        global current_f = fnum

        # problem settings
        f, F, lower_D, upper_D, lower_bounds, upper_bounds = getBilevel(fnum)

        for r = 1:NRUNS
            global current_r = r
            x, Fv, fv = BCA(F, f, upper_D, lower_D, upper_bounds, lower_bounds)
            Fs[fnum, r] = Fv
            fs[fnum, r] = fv

            @printf("%d \t %d \t %e \t %e\n", fnum, r, Fv, fv)
        end

        writecsv("output/leader$(fnum).csv", Fs[fnum,:])
        writecsv("output/follower$(fnum).csv", fs[fnum,:])
    end

    writecsv("summary/leader_fx.csv", Fs)
    writecsv("summary/follower_fx.csv", fs)

    printSummary("summary/leader_fx.csv")
    println("------------------")
    printSummary("summary/follower_fx.csv")
end



main()

statsToLatex("summary/leader_fx.csv"; mapping= x->abs.(x))
statsToLatex("summary/follower_fx.csv"; mapping= x->abs.(x))