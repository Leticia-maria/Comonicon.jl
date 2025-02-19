module TestLeafOptions

using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body
using Test

const test_args = Ref{Vector{Any}}()
const test_kwargs = Ref{Vector{Any}}()

function foo(; kwargs...)
    test_kwargs[] = [kwargs...]
end

cmd = Entry(;
    version = v"1.1.0",
    root = LeafCommand(;
        fn = foo,
        name = "leaf",
        options = Dict(
            "option-a" => Option(; sym = :option_a, hint = "int", type = Int, short = true),
            "option-b" => Option(; sym = :option_b, hint = "float64", type = Float64),
        ),
        flags = Dict(
            "flag-a" => Flag(; sym = :flag_a, short = true),
            "flag-b" => Flag(; sym = :flag_b),
        ),
    ),
)

eval(emit(cmd))

@testset "test leaf options" begin
    @test command_main(["--option-a=3", "--option-b", "1.2", "-f", "--flag-b"]) == 0
    @test test_kwargs[] == [:option_a => 3, :option_b => 1.2, :flag_a => true, :flag_b => true]
    @test command_main(["-o=3", "--option-b", "1.2", "-f", "--flag-b"]) == 0
    @test test_kwargs[] == [:option_a => 3, :option_b => 1.2, :flag_a => true, :flag_b => true]
    @test command_main(["-o3", "--option-b", "1.2", "-f", "--flag-b"]) == 0
    @test test_kwargs[] == [:option_a => 3, :option_b => 1.2, :flag_a => true, :flag_b => true]
    @test command_main(["--option-a", "--option-b", "1.2", "-f", "--flag-b"]) == 1
    @test command_main(["-o", "--option-b", "1.2", "-f", "--flag-b"]) == 1
end

end
