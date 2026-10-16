# Synopsys environment for this example: source setup.sh
module load synopsys-2024
# Point to the ASAP7 PDK, which is required for this example
export LD_PRELOAD="/lib64/libcrypto.so.1.1 /lib64/libssl.so.1.1 /lib64/libk5crypto.so.3"
# ASAP7 7nm predictive PDK, prepared for Synopsys (.db, .tf, NDM, TLU+)
export ASAP7=/work/zhang-x1/users/ry375/asap7_snps
