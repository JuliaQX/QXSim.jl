
using QXTns
using QXTools
using QXTools.Circuits

@testset "Test circuit to Tensor Network Circuit conversion" begin
    circ = create_test_circuit()

    # check tensornetwork size when no input or output
    tnc = convert_to_tnc(circ, no_input=true, no_output=true, decompose=false)
    @test QXTns.qubits(tnc) == 3
    @test length(tnc) == 3
    # make sure there are gates on all qubits as expected
    @test all(tnc.input_indices .!= tnc.output_indices)

    tnc = convert_to_tnc(circ, no_input=true, no_output=true, decompose=true)
    @test qubits(tnc) == 3
    @test length(tnc) == 5
    # make sure there are gates on all qubits as expected
    @test all(tnc.input_indices .!= tnc.output_indices)

    # convert again adding input
    tnc = convert_to_tnc(circ, no_input=false, no_output=true, decompose=false)
    @test length(tnc) == 6

    # check data of first tensor matches that of first gate
    @test tensor_data(tnc, first(keys(tnc))) == gate_matrix(first(circ.circ_ops))
end

@testset "Test simple circuit contraction to verify conversion to circuit working" begin
    circ = create_test_circuit()
    # we add input but no output to get full output vector
    tnc = convert_to_tnc(circ, no_input=false, no_output=true)
    tnc.tn.tensor_map
    # disable_hyperindices!(tnc.tn)
    output = QXTns.simple_contraction(tnc.tn); output = reshape(output, prod(size(output)))

    ref = zeros(8)
    ref[[1,8]] .= 1/sqrt(2)
    @test all(output .≈ ref)

    tnc = convert_to_tnc(circ, no_input=false, no_output=true, decompose=false)

    output = simple_contraction(tnc)
    output = reshape(output, prod(size(output)))
    ref = zeros(8)
    ref[[1,8]] .= 1/sqrt(2)
    @test all(output .≈ ref)
end