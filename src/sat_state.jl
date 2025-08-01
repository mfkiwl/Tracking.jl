struct SatState{
    C<:AbstractCorrelator,
    PCF<:Maybe{<:AbstractPostCorrFilter},
    DE<:Maybe{<:AbstractSatDopplerEstimator},
    DC<:Maybe{<:AbstractSatDownconvertAndCorrelator},
    P<:Maybe{AbstractSatPostProcess},
}
    prn::Int
    code_phase::Float64
    code_doppler::typeof(1.0Hz)
    carrier_phase::Float64
    carrier_doppler::typeof(1.0Hz)
    integrated_samples::Int
    signal_start_sample::Int
    correlator::C
    last_fully_integrated_correlator::C
    last_fully_integrated_filtered_prompt::ComplexF64
    sc_bit_detector::SecondaryCodeOrBitDetector
    cn0_estimator::MomentsCN0Estimator
    bit_buffer::BitBuffer
    post_corr_filter::PCF
    doppler_estimator::DE
    downconvert_and_correlator::DC
    post_process::P
end

get_prn(s::SatState) = s.prn
get_num_ants(s::SatState{<:AbstractCorrelator{M}}) where {M} = M
get_code_phase(s::SatState) = s.code_phase
get_code_doppler(s::SatState) = s.code_doppler
get_carrier_phase(s::SatState) = s.carrier_phase * 2π
get_carrier_doppler(s::SatState) = s.carrier_doppler
get_integrated_samples(s::SatState) = s.integrated_samples
get_signal_start_sample(s::SatState) = s.signal_start_sample
get_correlator(s::SatState) = s.correlator
get_last_fully_integrated_correlator(s::SatState) = s.last_fully_integrated_correlator
get_last_fully_integrated_filtered_prompt(s::SatState) =
    s.last_fully_integrated_filtered_prompt
get_secondary_code_or_bit_detector(s::SatState) = s.sc_bit_detector
get_post_corr_filter(s::SatState) = s.post_corr_filter
get_cn0_estimator(s::SatState) = s.cn0_estimator
get_bit_buffer(s::SatState) = s.bit_buffer
get_doppler_estimator(s::SatState) = s.doppler_estimator
get_downconvert_and_correlator(s::SatState) =
    s.downconvert_and_correlator, get_post_process(s::SatState) = s.post_process

function SatState(
    system::AbstractGNSS,
    prn::Int,
    sampling_frequency,
    code_phase,
    carrier_doppler;
    num_ants::NumAnts = NumAnts(1),
    correlator = get_default_correlator(system, sampling_frequency, num_ants),
    carrier_phase = 0.0,
    code_doppler = carrier_doppler * get_code_center_frequency_ratio(system),
    num_prompts_for_cn0_estimation::Int = 100,
    post_corr_filter::Maybe{AbstractPostCorrFilter} = DefaultPostCorrFilter(),
    doppler_estimator::Maybe{AbstractSatDopplerEstimator} = ConventionalPLLAndDLL(
        carrier_doppler,
        code_doppler,
    ),
    downconvert_and_correlator::Maybe{AbstractSatDownconvertAndCorrelator} = nothing,
    post_process::Maybe{AbstractSatPostProcess} = NoSatPostProcess(),
)
    SatState(
        prn,
        float(code_phase),
        float(code_doppler),
        float(carrier_phase) / 2π,
        float(carrier_doppler),
        0,
        1,
        correlator,
        correlator,
        complex(0.0, 0.0),
        SecondaryCodeOrBitDetector(),
        MomentsCN0Estimator(num_prompts_for_cn0_estimation),
        BitBuffer(),
        post_corr_filter,
        doppler_estimator,
        downconvert_and_correlator,
        post_process,
    )
end

function SatState(acq::AcquisitionResults; args...)
    SatState(
        acq.system,
        acq.prn,
        acq.sampling_frequency,
        acq.code_phase,
        acq.carrier_doppler;
        args...,
    )
end

function SatState(
    sat_state::SatState{C,PCF,DE,DC,P};
    prn = nothing,
    code_phase = nothing,
    code_doppler = nothing,
    carrier_phase = nothing,
    carrier_doppler = nothing,
    integrated_samples = nothing,
    signal_start_sample = nothing,
    correlator = nothing,
    last_fully_integrated_correlator = nothing,
    last_fully_integrated_filtered_prompt = nothing,
    sc_bit_detector = nothing,
    cn0_estimator = nothing,
    bit_buffer = nothing,
    post_corr_filter = nothing,
    doppler_estimator = nothing,
    downconvert_and_correlator = nothing,
    post_process = nothing,
) where {
    C<:AbstractCorrelator,
    PCF<:Maybe{<:AbstractPostCorrFilter},
    DE<:Maybe{<:AbstractSatDopplerEstimator},
    DC<:Maybe{<:AbstractSatDownconvertAndCorrelator},
    P<:Maybe{AbstractSatPostProcess},
}
    SatState{C,PCF,DE,DC,P}(
        isnothing(prn) ? sat_state.prn : prn,
        isnothing(code_phase) ? sat_state.code_phase : code_phase,
        isnothing(code_doppler) ? sat_state.code_doppler : code_doppler,
        isnothing(carrier_phase) ? sat_state.carrier_phase : carrier_phase,
        isnothing(carrier_doppler) ? sat_state.carrier_doppler : carrier_doppler,
        isnothing(integrated_samples) ? sat_state.integrated_samples : integrated_samples,
        isnothing(signal_start_sample) ? sat_state.signal_start_sample :
        signal_start_sample,
        isnothing(correlator) ? sat_state.correlator : correlator,
        isnothing(last_fully_integrated_correlator) ?
        sat_state.last_fully_integrated_correlator : last_fully_integrated_correlator,
        isnothing(last_fully_integrated_filtered_prompt) ?
        sat_state.last_fully_integrated_filtered_prompt :
        last_fully_integrated_filtered_prompt,
        isnothing(sc_bit_detector) ? sat_state.sc_bit_detector : sc_bit_detector,
        isnothing(cn0_estimator) ? sat_state.cn0_estimator : cn0_estimator,
        isnothing(bit_buffer) ? sat_state.bit_buffer : bit_buffer,
        isnothing(post_corr_filter) ? sat_state.post_corr_filter : post_corr_filter,
        isnothing(doppler_estimator) ? sat_state.doppler_estimator : doppler_estimator,
        isnothing(downconvert_and_correlator) ? sat_state.downconvert_and_correlator :
        downconvert_and_correlator,
        isnothing(post_process) ? sat_state.post_process : post_process,
    )
end

function SatState(
    sat_state::SatState{C,PCF,DE,Nothing,P},
    downconvert_and_correlator::DC,
) where {
    C<:AbstractCorrelator,
    PCF<:Maybe{<:AbstractPostCorrFilter},
    DE<:Maybe{<:AbstractSatDopplerEstimator},
    DC<:AbstractSatDownconvertAndCorrelator,
    P<:Maybe{AbstractSatPostProcess},
}
    SatState{C,PCF,DE,DC,P}(
        sat_state.prn,
        sat_state.code_phase,
        sat_state.code_doppler,
        sat_state.carrier_phase,
        sat_state.carrier_doppler,
        sat_state.integrated_samples,
        sat_state.signal_start_sample,
        sat_state.correlator,
        sat_state.last_fully_integrated_correlator,
        sat_state.last_fully_integrated_filtered_prompt,
        sat_state.sc_bit_detector,
        sat_state.cn0_estimator,
        sat_state.bit_buffer,
        sat_state.post_corr_filter,
        sat_state.doppler_estimator,
        downconvert_and_correlator,
        sat_state.post_process,
    )
end

function reset_start_sample(sat_state)
    SatState(sat_state; signal_start_sample = 1)
end

struct SystemSatsState{
    S<:AbstractGNSS,
    SS<:SatState,
    DE<:Maybe{AbstractSystemDopplerEstimator},
    DC<:Maybe{AbstractSystemDownconvertAndCorrelator},
    P<:Maybe{AbstractSystemPostProcess},
    I,
}
    system::S
    states::Dictionary{I,SS}
    doppler_estimator::DE
    downconvert_and_correlator::DC
    post_process::P
end

const MultipleSystemSatsState{N,S,SS,DE,DC,P,I} =
    TupleLike{<:NTuple{N,SystemSatsState{<:S,<:SS,<:DE,<:DC,<:P,<:I}}}

function merge_sats(
    multiple_system_sats_state::MultipleSystemSatsState{N},
    system_idx,
    new_sat_states::Dictionary{I,<:SatState},
    num_samples::Int,
) where {N,I}
    system_sats_state = get_system_sats_state(multiple_system_sats_state, system_idx)
    initiated_new_sat_states = map(
        sat_state -> initiate_downconvert_and_correlator(
            system_sats_state.system,
            sat_state,
            num_samples,
        ),
        new_sat_states,
    )
    @set multiple_system_sats_state[system_idx].states =
        merge(system_sats_state.states, initiated_new_sat_states)
end

function reset_start_sample(multiple_system_sats_state::MultipleSystemSatsState)
    map(multiple_system_sats_state) do system_sats_state
        new_sat_states = map(reset_start_sample, system_sats_state.states)
        SystemSatsState(system_sats_state, new_sat_states)
    end
end

function to_dictionary(sat_states::Dictionary{I,<:SatState}) where {I}
    sat_states
end

function to_dictionary(sat_states::Vector{<:SatState})
    Dictionary(map(get_prn, sat_states), sat_states)
end

function to_dictionary(sat_state::SatState)
    dictionary((get_prn(sat_state) => sat_state,))
end

function SystemSatsState(
    system::AbstractGNSS,
    states;
    doppler_estimator::Maybe{AbstractSystemDopplerEstimator} = SystemConventionalPLLAndDLL(),
    downconvert_and_correlator::Maybe{AbstractSystemDownconvertAndCorrelator} = nothing,
    post_process::Maybe{AbstractSystemPostProcess} = NoSystemPostProcess(),
)
    SystemSatsState(
        system,
        to_dictionary(states),
        doppler_estimator,
        downconvert_and_correlator,
        post_process,
    )
end

function SystemSatsState(
    system_sats_state::SystemSatsState,
    states::Dictionary{I,<:SatState};
    doppler_estimator = system_sats_state.doppler_estimator,
    downconvert_and_correlator = system_sats_state.downconvert_and_correlator,
    post_process = system_sats_state.post_process,
) where {I}
    SystemSatsState(
        system_sats_state.system,
        states,
        doppler_estimator,
        downconvert_and_correlator,
        post_process,
    )
end

get_system(sss::SystemSatsState) = sss.system
get_states(sss::SystemSatsState) = sss.states
get_sat_state(sss::SystemSatsState, identifier) = sss.states[identifier]
get_downconvert_and_correlator(sss::SystemSatsState) = sss.downconvert_and_correlator
get_post_process(sss::SystemSatsState) = sss.post_process

function estimate_cn0(sss::SystemSatsState, sat_identifier)
    system = sss.system
    estimate_cn0(
        get_cn0_estimator(get_sat_state(sss, sat_identifier)),
        get_code_length(system) / get_code_frequency(system),
    )
end
