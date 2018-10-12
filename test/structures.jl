using Symbolics, Test

@sym x y t

@testset "   UpTuple and DownTuple" begin
    # UpTuple
    ut = UpTuple([x, x^2, -x-y])
    @test ut == ut
    @test string(ut) == "up(x\n   x ^ 2\n   (x + y) * -1)"
    @test (ut(t)).data == [x(t), (x^2)(t), (-x-y)(t)]
    @test string(ut(t)) == string(  UpTuple([x(t), (x^2)(t), (-x-y)(t)])  )
    @test up(ut.data) == ut
    @test ut[2] == x^2
    ut[2] = y
    @test y == ut[2]
    @test ut.data == [x, y, -x-y]
    # DownTuple
    dt = DownTuple([x, x^2, -x-y])
    @test dt == dt
    @test (dt(t)).data == [x(t), (x^2)(t), (-x-y)(t)]
    @test down(dt.data) == dt

    P = up([x^2-1, sin(y)])
    Q = up([x^2-1, sin(y)])

    @test P == Q
    @test all(Q .== P)
end
