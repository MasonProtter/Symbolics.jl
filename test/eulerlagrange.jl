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

    # Lagrangian for the free particle in space (3D)
    function L_free_3d(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (qdot[1]^2+qdot[2]^2+qdot[3]^2)/2
    end

    q = UpTuple([x, y, z])

    lagrange_eqs_fp3d = Lagrange_Equations(L_free_3d)(q)
    lagrange_eqs_fp3d_t = Lagrange_Equations(L_free_3d)(q)(t)
    @test typeof(lagrange_eqs_fp3d_t) == UpTuple
    fp3d_eqs = [(D(D(x)))(t), (D(D(y)))(t), (D(D(z)))(t)] # eqs of motion for the free particle in space
    @test lagrange_eqs_fp3d_t.data == fp3d_eqs
    @test lagrange_eqs_fp3d_t == up(fp3d_eqs)
    @test lagrange_eqs_fp3d_t == UpTuple(fp3d_eqs)
    @test lagrange_eqs_fp3d(t).data == fp3d_eqs
    @test lagrange_eqs_fp3d(t) == up(fp3d_eqs)
    @test lagrange_eqs_fp3d(t) == UpTuple(fp3d_eqs)

    # Lagrangian for the Kepler problem
    function L_kepler(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        r = (q[1]^2+q[2]^2)^(1/2)
        (qdot[1]^2+qdot[2]^2)*(m/2)+μ/r
    end

    q = UpTuple([x, y])

    # Equivalent to Eq. (1.48) of SICM
    lagrange_eqs_kepler = Lagrange_Equations(L_kepler)(q)
    lagrange_eqs_kepler_t = Lagrange_Equations(L_kepler)(q)(t)
    @test typeof(lagrange_eqs_kepler_t) == UpTuple
    kepler_eqs = [m * (D(D(x)))(t) + ((x)(t) ^ 2 + (y)(t) ^ 2) ^ -1.5 * (x)(t) * μ, m * (D(D(y)))(t) + ((x)(t) ^ 2 + (y)(t) ^ 2) ^ -1.5 * (y)(t) * μ]
    @test lagrange_eqs_kepler_t.data == kepler_eqs
    @test lagrange_eqs_kepler_t == up(kepler_eqs)
    @test lagrange_eqs_kepler_t == UpTuple(kepler_eqs)
    @test lagrange_eqs_kepler(t).data == kepler_eqs
    @test lagrange_eqs_kepler(t) == up(kepler_eqs)
    @test lagrange_eqs_kepler(t) == UpTuple(kepler_eqs)

end
