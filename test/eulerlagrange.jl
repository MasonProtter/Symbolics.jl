using Symbolics, Test

@sym x y z m ω t μ

@testset "   Euler-Lagrange Solver" begin
    function Γ(w)
       t -> UpTuple([t, w(t), D(w)(t)])
    end

    function Lagrange_Equations(L)
        w -> D(∂(3)(L)∘Γ(w)) - ∂(2)(L)∘Γ(w)
    end

    function L_SHO(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (0.5m)*qdot^2 - (0.5m*ω^2)*q^2
    end

    function L_free(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (0.5m)*qdot^2
    end

    function L_pendulum(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        m*qdot^2/2+cos(q)
    end

    @test Lagrange_Equations(L_SHO)(x)(t)  == (D(D(x)))(t) * m + (x)(t) * m * ω ^ 2
    @test Lagrange_Equations(L_free)(x)(t) == (D(D(x)))(t) * m
    @test Lagrange_Equations(L_pendulum)(x)(t) == (D(D(x)))(t) * m + sin((x)(t))

    function L_free_3d(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (qdot[1]^2+qdot[2]^2+qdot[3]^2)/2
    end

    q = UpTuple([x, y, z])

    @test Lagrange_Equations(L_free_3d)(q)(t).data == [(D(D(x)))(t), (D(D(y)))(t), (D(D(z)))(t)]

    function L_kepler(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        r = (q[1]^2+q[2]^2)^(1/2)
        (qdot[1]^2+qdot[2]^2)*(m/2)+μ/r
    end

    q = UpTuple([x, y])

    # Equivalent to Eq. (1.48) of SICM
    @test Lagrange_Equations(L_kepler)(q)(t).data == SymExpr[m * (D(D(x)))(t) + ((x)(t) ^ 2 + (y)(t) ^ 2) ^ -1.5 * (x)(t) * μ, m * (D(D(y)))(t) + ((x)(t) ^ 2 + (y)(t) ^ 2) ^ -1.5 * (y)(t) * μ]

end
