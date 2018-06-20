import numpy as np
import scipy.linalg
from pyquil.gates import MEASURE

def damping_channel(damp_prob=.1):
    """
    Generate the Kraus operators corresponding to an amplitude damping
    noise channel.

    :params float damp_prob: The one-step damping probability.
    :return: A list [k1, k2] of the Kraus operators that parametrize the map.
    :rtype: list
    """
    damping_op = np.sqrt(damp_prob) * np.array([[0, 1],
                                                [0, 0]])

    residual_kraus = np.diag([1, np.sqrt(1-damp_prob)])
    return [residual_kraus, damping_op]

def append_kraus_to_gate(kraus_ops, g):
    """
    Follow a gate `g` by a Kraus map described by `kraus_ops`.

    :param list kraus_ops: The Kraus operators.
    :param numpy.ndarray g: The unitary gate.
    :return: A list of transformed Kraus operators.
    """
    return [kj.dot(g) for kj in kraus_ops]


def append_damping_to_gate(gate, damp_prob=.1):
    """
    Generate the Kraus operators corresponding to a given unitary
    single qubit gate followed by an amplitude damping noise channel.

    :params np.ndarray|list gate: The 2x2 unitary gate matrix.
    :params float damp_prob: The one-step damping probability.
    :return: A list [k1, k2] of the Kraus operators that parametrize the map.
    :rtype: list
    """
    return append_kraus_to_gate(damping_channel(damp_prob), gate)

# RX(0.1)
RXdphi = scipy.linalg.expm(-.5j*.1*np.array([[0, 1],
                                             [1, 0]]))

def batch_run_noisy_qvm(progs, qvm, trials=500, damping=0.2):
    # Run on the QVM
    results = []
    qubits = set()
    for prog in progs:
        qubits |= prog.get_qubits()
        prog.defgate("RXdphi", RXdphi)
        for q in qubits:
            prog.define_noisy_gate("I", [q], append_damping_to_gate(np.eye(2), damping))
            prog.define_noisy_gate("RXdphi", [q], append_damping_to_gate(RXdphi, damping))
        prog.inst([MEASURE(qq, [qq]) for qq in qubits])
        qvm.random_seed = int(progs.index(prog) + 2)
        result = qvm.run(prog, list(range(max(qubits) + 1)), trials)
        results.append(result)
    results = np.array(results)
    return results