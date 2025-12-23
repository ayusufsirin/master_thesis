import numpy as np
import matplotlib.pyplot as plt

# Generate a "true" signal (sine with a little harmonic for realism)
n = 512
x = np.linspace(0, 2*np.pi, n, endpoint=False)
true = np.sin(2*x) + 0.25*np.sin(5*x)

# Anchor (known) samples: sparse points
rng = np.random.default_rng(7)
anchor_idx = np.sort(rng.choice(n, size=40, replace=False))
mask = np.zeros(n, dtype=bool)
mask[anchor_idx] = True
anchors = np.full(n, np.nan)
anchors[mask] = true[mask]

# Simple PG-like iterative reconstruction:
# - start with zeros
# - enforce known samples in time domain
# - low-pass in frequency domain (bandlimit constraint)
def lowpass(sig, keep=35):
    F = np.fft.rfft(sig)
    # keep low frequencies, zero-out high frequencies
    F[keep:] = 0
    return np.fft.irfft(F, n=sig.size)

recon = np.zeros_like(true)
iters_to_show = [0, 1, 2, 5, 12]
recons = {}

for t in range(max(iters_to_show)+1):
    if t in iters_to_show:
        recons[t] = recon.copy()
    # Enforce anchor samples (data constraint)
    recon[mask] = true[mask]
    # Enforce bandlimit (spectral constraint)
    recon = lowpass(recon, keep=35)

# Plot
plt.figure(figsize=(10, 4.8))
plt.plot(x, true, label="Gerçek sinyal (hedef)", linewidth=2)

# Anchor points as markers
plt.plot(x[mask], true[mask], linestyle="None", marker="o", label="Ankraj örnekler (bilinen noktalar)")

# Iterative reconstructions
for t in iters_to_show:
    if t == 0:
        lbl = "İterasyon 0 (başlangıç)"
    else:
        lbl = f"İterasyon {t}"
    plt.plot(x, recons[t], label=lbl, linewidth=1)

plt.xlabel("Örnekleme ekseni (faz)")
plt.ylabel("Genlik")
plt.title("Standart Papoulis–Gerchberg: Kayıp örneklerin ankrajlara göre iteratif yakınsaması")
plt.legend(loc="upper right", fontsize=8)
plt.tight_layout()

out_path = "/mnt/data/standard_pg_convergence.png"
plt.savefig(out_path, dpi=200)
out_path
