# Please make sure that you have 'stack' installed. 
# https://github.com/commercialhaskell/stack/blob/master/doc/install_and_upgrade.md

TAMARIN=~/.local/bin/tamarin-prover
SAPIC=~/.local/bin/sapic

# Default installation via stack, multi-threaded
# Try to install Tamarin
default: tamarin

# Default Tamarin installation via stack, multi-threaded
.PHONY: tamarin
tamarin:
	stack setup
	stack install

# Single-threaded Tamarin
.PHONY: single
single: 
	stack setup
	stack install --flag tamarin-prover:-threaded

# Tamarin with profiling options, single-threaded
.PHONY: profiling
profiling:
	stack setup
	stack install --no-system-ghc --executable-profiling --library-profiling --ghc-options="-fprof-auto -rtsopts" --flag tamarin-prover:-threaded

# SAPIC
.PHONY: sapic
sapic:
	cd plugins/sapic && $(MAKE)

# Clean target for SAPIC
.PHONY: sapic-clean
sapic-clean:
	cd plugins/sapic && $(MAKE) clean

# Clean target for Tamarin
.PHONY: tamarin-clean
tamarin-clean:
	stack clean

# Clean Tamarin and SAPIC
.PHONY: clean
clean:	tamarin-clean sapic-clean

# ###########################################################################
# NOTE the remainder makefile is FOR DEVELOPERS ONLY.
# It is by no means official in any form and should be IGNORED :-)
# ###########################################################################

VERSION=1.5.1

###############################################################################
## Case Studies
###############################################################################


## CSF'12
#########

# These case studies are located in examples/
DH2=DH2_original.spthy

KAS=KAS1.spthy KAS2_eCK.spthy KAS2_original.spthy

KEA=KEA_plus_KI_KCI.spthy KEA_plus_KI_KCI_wPFS.spthy

NAXOS=NAXOS_eCK_PFS.spthy NAXOS_eCK.spthy

SDH=SignedDH_PFS.spthy #SignedDH_eCK.spthy
# The "SignedDH_eCK.spthy" case study has not been working for a long time, 
# probably some change in the heuristics somewhere made it run indefinitely.

STS=STS_MAC.spthy STS_MAC_fix1.spthy STS_MAC_fix2.spthy

JKL1=JKL_TS1_2004_KI.spthy JKL_TS1_2008_KI.spthy
JKL2=JKL_TS2_2004_KI_wPFS.spthy JKL_TS2_2008_KI_wPFS.spthy
JKL3=JKL_TS3_2004_KI_wPFS.spthy JKL_TS3_2008_KI_wPFS.spthy

UM=UM_wPFS.spthy UM_PFS.spthy


CSF12_CASE_STUDIES=$(JKL1) $(JKL2) $(KEA) $(NAXOS) $(UM) $(STS) $(SDH) $(KAS) $(DH2)
CSF12_CS_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/csf12/,$(CSF12_CASE_STUDIES)))

# CSF'12 case studies
csf12-case-studies:	$(CSF12_CS_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/csf12/*.spthy

# individual case studies
case-studies/%_analyzed.spthy:	examples/%.spthy $(TAMARIN)
	mkdir -p $(dir $@)
	# Use -N3, as the fourth core is used by the OS and the console
	$(TAMARIN) $< --prove --stop-on-trace=dfs +RTS -N3 -RTS -o$<.tmp >$<.out
	# We only produce the target after the run, otherwise aborted
	# runs already 'finish' the case.
	printf "\n/* Output\n" >>$<.tmp
	cat $<.out >>$<.tmp
	echo "*/" >>$<.tmp
	mv $<.tmp $@
	\rm -f $<.out

# individual case studies, special case with oracle
case-studies/%_analyzed-oracle-chaum.spthy: examples/%.spthy $(TAMARIN)
	mkdir -p case-studies/csf18-xor
	# Use -N3, as the fourth core is used by the OS and the console
	$(TAMARIN) $< --prove --stop-on-trace=dfs --heuristic=O --oraclename=examples/csf18-xor/chaum_offline_anonymity.oracle +RTS -N3 -RTS -o$<.tmp >$<.out
	# We only produce the target after the run, otherwise aborted
	# runs already 'finish' the case.
	printf "\n/* Output\n" >>$<.tmp
	cat $<.out >>$<.tmp
	echo "*/" >>$<.tmp
	mv $<.tmp $@
	\rm -f $<.out

# individual case studies, special case with sequential dfs
case-studies/%_analyzed-seqdfs.spthy: examples/%.spthy $(TAMARIN)
	mkdir -p case-studies/regression/trace
	# Use -N3, as the fourth core is used by the OS and the console
	$(TAMARIN) $< --prove --stop-on-trace=seqdfs +RTS -N3 -RTS -o$<.tmp >$<.out
	# We only produce the target after the run, otherwise aborted
	# runs already 'finish' the case.
	printf "\n/* Output\n" >>$<.tmp
	cat $<.out >>$<.tmp
	echo "*/" >>$<.tmp
	mv $<.tmp $@
	\rm -f $<.out


## Observational Equivalence
############################

# individual diff-based case studies
case-studies/%_analyzed-diff.spthy:	examples/%.spthy $(TAMARIN)
	mkdir -p case-studies/ccs15
	mkdir -p case-studies/features/equivalence
	mkdir -p case-studies/post17
	mkdir -p case-studies/regression/diff
	mkdir -p case-studies/csf18-xor/diff-models
	# Use -N3, as the fourth core is used by the OS and the console
	# For execution on server using -N14 for faster completion!
	$(TAMARIN) $< --prove --diff --stop-on-trace=dfs +RTS -N14 -RTS -o$<.tmp >$<.out
	# We only produce the target after the run, otherwise aborted
	# runs already 'finish' the case.
	printf "\n/* Output\n" >>$<.tmp
	cat $<.out >>$<.tmp
	echo "*/" >>$<.tmp
	mv $<.tmp $@
	\rm -f $<.out

# individual diff-based precomputed (no --prove) case studies
case-studies/%_analyzed-diff-noprove.spthy:	examples/%.spthy $(TAMARIN)
	mkdir -p case-studies/ccs15
	mkdir -p case-studies/features/equivalence
	mkdir -p case-studies/regression/diff
	mkdir -p case-studies/csf18-xor/diff-models
	# Use -N3, as the fourth core is used by the OS and the console
	$(TAMARIN) $< --diff --stop-on-trace=dfs +RTS -N3 -RTS -o$<.tmp >$<.out
	# We only produce the target after the run, otherwise aborted
	# runs already 'finish' the case.
	printf "\n/* Output\n" >>$<.tmp
	cat $<.out >>$<.tmp
	echo "*/" >>$<.tmp
	mv $<.tmp $@
	\rm -f $<.out

# individual diff-based case studies running only on the Observational_equivalence lemma
case-studies/%_analyzed-diff-obseqonly.spthy:	examples/%.spthy $(TAMARIN)
	mkdir -p case-studies/csf18-xor/diff-models
	# Use -N3, as the fourth core is used by the OS and the console
	$(TAMARIN) $< --prove=Observational_equivalence --diff --stop-on-trace=dfs +RTS -N3 -RTS -o$<.tmp >$<.out
	# We only produce the target after the run, otherwise aborted
	# runs already 'finish' the case.
	printf "\n/* Output\n" >>$<.tmp
	cat $<.out >>$<.tmp
	echo "*/" >>$<.tmp
	mv $<.tmp $@
	\rm -f $<.out

CCS15_CASE_STUDIES=DDH.spthy  probEnc.spthy  rfid-feldhofer.spthy
CCS15_CS_TARGETS=$(subst .spthy,_analyzed-diff.spthy,$(addprefix case-studies/ccs15/,$(CCS15_CASE_STUDIES)))

CCS15_PRECOMPUTED_CASE_STUDIES=Attack_TPM_Envelope.spthy
CCS15_PCS_TARGETS=$(subst .spthy,_analyzed-diff-noprove.spthy,$(addprefix case-studies/ccs15/,$(CCS15_PRECOMPUTED_CASE_STUDIES)))

CCS15_TARGETS= $(CCS15_CS_TARGETS) $(CCS15_PCS_TARGETS)

# CCS15 case studies
ccs15-case-studies:	$(CCS15_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/ccs15/*.spthy


REGRESSION_OBSEQ_CASE_STUDIES=issue223.spthy issue198-1.spthy issue198-2.spthy issue324.spthy issue331.spthy
REGRESSION_OBSEQ_TARGETS=$(subst .spthy,_analyzed-diff.spthy,$(addprefix case-studies/regression/diff/,$(REGRESSION_OBSEQ_CASE_STUDIES)))

TESTOBSEQ_CASE_STUDIES=AxiomDiffTest1.spthy AxiomDiffTest2.spthy AxiomDiffTest3.spthy AxiomDiffTest4.spthy N5N6DiffTest.spthy
TESTOBSEQ_TARGETS=$(subst .spthy,_analyzed-diff.spthy,$(addprefix case-studies/features/equivalence/,$(TESTOBSEQ_CASE_STUDIES))) $(REGRESSION_OBSEQ_TARGETS)

OBSEQ_TARGETS= $(CCS15_TARGETS) $(TESTOBSEQ_TARGETS)

#Observational equivalence test case studies:
obseq-test-case-studies:	$(TESTOBSEQ_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/features/equivalence/*.spthy case-studies/regression/diff/*.spthy

#Observational equivalence case studies with CCS15
obseq-case-studies:	$(OBSEQ_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/ccs15/*.spthy case-studies/features/equivalence/*.spthy


## non-subterm convergent equational theories
#############################################
POST17_TRACE_CASE_STUDIES= chaum_unforgeability.spthy foo_eligibility.spthy okamoto_eligibility.spthy needham_schroeder_symmetric_cbc.spthy denning_sacco_symmetric_cbc.spthy
POST17_TRACE_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/post17/,$(POST17_TRACE_CASE_STUDIES)))

POST17_DIFF_CASE_STUDIES= chaum_anonymity.spthy chaum_untraceability.spthy foo_vote_privacy.spthy okamoto_receipt_freeness.spthy okamoto_vote_privacy.spthy
POST17_DIFF_TARGETS=$(subst .spthy,_analyzed-diff.spthy,$(addprefix case-studies/post17/,$(POST17_DIFF_CASE_STUDIES)))

POST17_TARGETS= $(POST17_TRACE_TARGETS)  $(POST17_DIFF_TARGETS)

# POST17 case studies
post17-case-studies:	$(POST17_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/post17/*.spthy

## XOR-using case studies
#########################

XOR_TRACE_CASE_STUDIES= NSLPK3xor.spthy CRxor.spthy CH07.spthy KCL07.spthy LAK06.spthy
XOR_TRACE_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/csf18-xor/,$(XOR_TRACE_CASE_STUDIES)))

XOR_TRACE_ORACLE_CASE_STUDIES= chaum_offline_anonymity.spthy
XOR_TRACE_ORACLE_TARGETS=$(subst .spthy,_analyzed-oracle-chaum.spthy,$(addprefix case-studies/csf18-xor/,$(XOR_TRACE_ORACLE_CASE_STUDIES)))

XOR_BASIC_TRACE_CASE_STUDIES= xor0.spthy xor1.spthy xor2.spthy xor3.spthy xor4.spthy xor-basic.spthy
XOR_BASIC_TRACE_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/features/xor/basicfunctionality/,$(XOR_BASIC_TRACE_CASE_STUDIES)))

# Includes 6 out of 9 diff-case studies from CSF18, excluding KCL07-UK1, LAK06-UK2, LAK06-UK3 due to runtime!
XOR_DIFF_CASE_STUDIES= CH07-UK1.spthy CH07-UK2.spthy  KCL07-UK2.spthy LAK06-UK1.spthy
XOR_DIFF_TARGETS=$(subst .spthy,_analyzed-diff.spthy,$(addprefix case-studies/csf18-xor/diff-models/,$(XOR_DIFF_CASE_STUDIES)))

XOR_DIFF_OBSEQONLY_CASE_STUDIES= CH07-UK3.spthy
XOR_DIFF_OBSEQONLY_TARGETS=$(subst .spthy,_analyzed-diff-obseqonly.spthy,$(addprefix case-studies/csf18-xor/diff-models/,$(XOR_DIFF_OBSEQONLY_CASE_STUDIES)))

XOR_DIFF_PRECOMPUTED_CASE_STUDIES= KCL07-UK3_attack.spthy
XOR_DIFF_PRECOMPUTED_TARGETS=$(subst .spthy,_analyzed-diff-noprove.spthy,$(addprefix case-studies/csf18-xor/diff-models/,$(XOR_DIFF_PRECOMPUTED_CASE_STUDIES)))

# XOR case studies
xor-trace-case-studies: $(XOR_BASIC_TRACE_TARGETS) $(XOR_TRACE_TARGETS) $(XOR_TRACE_ORACLE_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/features/xor/basicfunctionality/*.spthy case-studies/csf18-xor/*.spthy

xor-diff-case-studies: $(XOR_DIFF_TARGETS) $(XOR_DIFF_OBSEQONLY_TARGETS) $(XOR_DIFF_PRECOMPUTED_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/csf18-xor/diff-models/*.spthy

XOR_TARGETS=$(XOR_BASIC_TRACE_TARGETS) $(XOR_TRACE_TARGETS) $(XOR_TRACE_ORACLE_TARGETS) $(XOR_DIFF_TARGETS) $(XOR_DIFF_OBSEQONLY_TARGETS) $(XOR_DIFF_PRECOMPUTED_TARGETS)

xor-full-case-studies: $(XOR_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/features/xor/basicfunctionality/*.spthy case-studies/csf18-xor/*.spthy case-studies/csf18-xor/diff-models/*.spthy

## Inductive Strengthening
##########################

TPM=related_work/TPM_DKRS_CSF11/TPM_Exclusive_Secrets.spthy related_work/TPM_DKRS_CSF11/Envelope.spthy

STATVERIF=related_work/StatVerif_ARR_CSF11/StatVerif_Security_Device.spthy related_work/StatVerif_ARR_CSF11/StatVerif_GM_Contract_Signing.spthy

AIF=related_work/AIF_Moedersheim_CCS10/Keyserver.spthy

YUBIKEY=related_work/YubiSecure_KS_STM12/Yubikey.spthy related_work/YubiSecure_KS_STM12/Yubikey_and_YubiHSM.spthy related_work/YubiSecure_KS_STM12/Yubikey_multiset.spthy related_work/YubiSecure_KS_STM12/Yubikey_and_YubiHSM_multiset.spthy

LOOPS=loops/TESLA_Scheme1.spthy loops/Minimal_KeyRenegotiation.spthy loops/Minimal_Create_Use_Destroy.spthy loops/RFID_Simple.spthy loops/Minimal_Create_Use_Destroy.spthy loops/Minimal_Crypto_API.spthy loops/Minimal_Loop_Example.spthy loops/JCS12_Typing_Example.spthy loops/Minimal_Typing_Example.spthy loops/Typing_and_Destructors.spthy
# TESLA_Scheme2.spthy (not finished)

IND_CASE_STUDIES=$(TPM) $(AIF) $(LOOPS) $(STATVERIF) $(YUBIKEY)
IND_CS_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/,$(IND_CASE_STUDIES)))

# case studies
induction-case-studies:	$(IND_CS_TARGETS)
	grep -R "verified\|falsified\|processing time" case-studies/related_work/ case-studies/loops/


## Classical Protocols
######################


CLASSIC_CASE_STUDIES=TLS_Handshake.spthy NSPK3.spthy NSLPK3.spthy NSLPK3_untagged.spthy

CLASSIC_CS_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/classic/,$(CLASSIC_CASE_STUDIES)))

# case studies
classic-case-studies:	$(CLASSIC_CS_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/classic/*.spthy


## AKE Diffie-Hellman
####################

AKE_DH_CASE_STUDIES=DHKEA_NAXOS_C_eCK_PFS_keyreg_partially_matching.spthy DHKEA_NAXOS_C_eCK_PFS_partially_matching.spthy UM_one_pass_fix.spthy UM_three_pass.spthy NAXOS_eCK.spthy UM_three_pass_combined.spthy NAXOS_eCK_PFS.spthy UM_three_pass_combined_fixed.spthy UM_one_pass_attack.spthy

AKE_DH_CS_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/ake/dh/,$(AKE_DH_CASE_STUDIES)))

# case studies
ake-dh-case-studies:	$(AKE_DH_CS_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/ake/dh/*.spthy


## Bilinear Pairing
####################

AKE_BP_CASE_STUDIES=Chen_Kudla.spthy Chen_Kudla_eCK.spthy Joux.spthy Joux_EphkRev.spthy RYY.spthy RYY_PFS.spthy Scott.spthy Scott_EphkRev.spthy TAK1.spthy TAK1_eCK_like.spthy

AKE_BP_CS_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/ake/bilinear/,$(AKE_BP_CASE_STUDIES)))

# case studies
ake-bp-case-studies:	$(AKE_BP_CS_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/ake/bilinear/*.spthy


## Features
###########

FEATURES_CASE_STUDIES=cav13/DH_example.spthy features//multiset/counter.spthy features//private_function_symbols/NAXOS_eCK_PFS_private.spthy features//private_function_symbols/NAXOS_eCK_private.spthy features//injectivity/injectivity.spthy

FEATURES_CS_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/,$(FEATURES_CASE_STUDIES)))

# case studies
features-case-studies:	$(FEATURES_CS_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/features/multiset/*.spthy case-studies/features/private_function_symbols/*.spthy case-studies/cav13/*.spthy case-studies/features/injectivity/*.spthy

## Regression (old issues)
##########################

REGRESSION_CASE_STUDIES=issue216.spthy issue193.spthy issue310.spthy

REGRESSION_TARGETS=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/regression/trace/,$(REGRESSION_CASE_STUDIES)))

SEQDFS_CASE_STUDIES=seqdfsneeded.spthy
SEQDFS_TARGETS=$(subst .spthy,_analyzed-seqdfs.spthy,$(addprefix case-studies/regression/trace/,$(SEQDFS_CASE_STUDIES)))


# case studies
regression-case-studies:	$(REGRESSION_TARGETS) $(SEQDFS_TARGETS)
	grep "verified\|falsified\|processing time" case-studies/regression/trace/*.spthy


## SAPIC output in Tamarin
##########################

# FAST <=> processing time less than 10sec on Robert's current computer (per file)

SAPIC_CASE_STUDIES_FAST=basic/no-replication.spthy basic/replication.spthy basic/channels1.spthy basic/channels2.spthy basic/channels3.spthy  basic/design-choices.spthy basic/exclusive-secrets.spthy basic/reliable-channel.spthy \
basic/running-example.spthy \
basic/operator-precedence-1.spthy basic/operator-precedence-2.spthy basic/operator-precedence-3.spthy basic/operator-precedence-4.spthy basic/operator-precedence-5.spthy \
feature-let-bindings/let-blocks2.spthy feature-let-bindings/let-blocks3.spthy feature-let-bindings/match_new.spthy \
statVerifLeftRight/stateverif_left_right.spthy \
MoedersheimWebService/set-abstr.spthy MoedersheimWebService/set-abstr-lookup.spthy \
fairexchange-mini/mini10.spthy fairexchange-mini/mini2.spthy fairexchange-mini/mini4.spthy fairexchange-mini/mini6.spthy fairexchange-mini/mini8.spthy fairexchange-mini/ndc-nested-2.spthy fairexchange-mini/ndc-nested-4.spthy fairexchange-mini/ndc-nested.spthy fairexchange-mini/mini1.spthy fairexchange-mini/mini3.spthy fairexchange-mini/mini5.spthy fairexchange-mini/mini7.spthy fairexchange-mini/mini9.spthy fairexchange-mini/ndc-nested-3.spthy fairexchange-mini/ndc-nested-5.spthy fairexchange-mini/ndc-two-replications.spthy\
SCADA/opc_ua_secure_conversation.spthy \
feature-xor/CH07.spthy feature-xor/CRxor.spthy feature-xor/KCL07.spthy \
feature-secret-channel/secret-channel.spthy \
GJM-contract/contract.spthy \
feature-predicates/decwrap-destr-manual.spthy feature-predicates/decwrap-destr-restrict.spthy feature-predicates/decwrap-destr-restrict-variant.spthy feature-predicates/pub.spthy feature-predicates/simple_example.spthy feature-predicates/binding.spthy \
feature-predicates/binding.spthy \
feature-let-bindings/let-blocks.spthy \
feature-locations/AC.spthy \
feature-locations/AKE.spthy  \
feature-locations/licensing.spthy \
feature-locations/SOC.spthy \
feature-locations/OTP.spthy \
feature-locations/AC_counter_with_attack.spthy \
feature-locations/AC_sid_with_attack.spthy \
feature-ass-immediate/test-all.spthy 

# SLOW <=> processing time more than 10sec on Robert's current computer, but less than a day
SAPIC_CASE_STUDIES_SLOW= encWrapDecUnwrap/encwrapdecunwrap-nolocks.spthy \
NSL/nsl-no_as-untagged.spthy \
Yubikey/Yubikey.spthy \
encWrapDecUnwrap/encwrapdecunwrap.spthy

# SUPER SLOW <=> processing time more than a day or take's more memory than Robert's computer can take
SAPIC_CASE_STUDIES_SUPER_SLOW= fairexchange-km/km.spthy \
fairexchange-asw/aswAB.spthy \
examples/sapic/fairexchange-asw/asw-mod-weak-locks.spthy \
examples/sapic/fairexchange-asw/aswAB-mod.spthy \
fairexchange-gjm/gjm-locks-fakepcsbranch.spthy \
fairexchange-gjm/gjm-locks-unfairness-A.spthy

# The following case studies are in the repository, but cannot be proven automatically.
# PKCS11/pkcs11-templates.spthy 
# # heavy use of manual lemmas, not part of regresstion tests
#
# PKCS11/pkcs11-dynamic-policy.spthy \ 
# # not working 
#
# feature-xor/NSLPK3xor.spthy \
# # attack finding relies on sources lemma which is untrue. it is acceptable for
# # this model, because the attacks found despite an incorrect sources lemma are
# # correct by definition, but negating it would defeat its purpose, and removing
# # it would inhibit the attack finding. 
#
# envelope/envelope.spthy envelope/envelope_simpler.spthy envelope/envelope_allowsattack.spthy \ 
# # these examples were never completed and are here for reference only

# not working because of missing support for locations


SAPIC_CS_TARGETS_FAST=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/sapic/,$(SAPIC_CASE_STUDIES_FAST)))
SAPIC_CS_TARGETS_SLOW=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/sapic/,$(SAPIC_CASE_STUDIES_SLOW)))
SAPIC_CS_TARGETS_SUPER_SLOW=$(subst .spthy,_analyzed.spthy,$(addprefix case-studies/sapic/,$(SAPIC_CASE_STUDIES_SLOW)))

# lol:
# 	$(info $$var is [${SAPIC_CS_TARGETS}])

# case studies
sapic-case-studies:	$(SAPIC_CS_TARGETS_FAST) $(SAPIC_CS_TARGETS_SLOW) # used for regressions, skips super slow tests
	grep "verified\|falsified\|processing time" $^
sapic-case-studies-fast:	$(SAPIC_CS_TARGETS_FAST) # used for quick checks during development
	grep "verified\|falsified\|processing time" $^
sapic-case-studies-superslow:	$(SAPIC_CS_TARGETS_SUPER_SLOW) # used to heat in winter
	grep "verified\|falsified\|processing time" $^

## All case studies
###################


UNAME_S := $(shell uname -s)
case-studies/system.info:
	mkdir -p case-studies
	hostname > $@
ifeq ($(UNAME_S),Linux)
	cat /proc/cpuinfo  | grep 'name'| uniq >> $@
	cat /proc/cpuinfo  | grep process| wc -l >> $@
	cat /proc/meminfo  | grep 'MemTotal'| uniq >> $@
else 	# ($(UNAME_S),Darwin)
	sysctl hw >> $@
endif
#	top -b | head >> $@

CS_TARGETS=case-studies/Tutorial_analyzed.spthy $(CSF12_CS_TARGETS) $(CLASSIC_CS_TARGETS) $(IND_CS_TARGETS) $(AKE_DH_CS_TARGETS) $(AKE_BP_CS_TARGETS) $(FEATURES_CS_TARGETS) $(OBSEQ_TARGETS) $(SAPIC_TAMARIN_CS_TARGETS) $(POST17_TARGETS) $(REGRESSION_TARGETS) $(XOR_TARGETS)

case-studies: 	case-studies/system.info $(CS_TARGETS) 
	grep -R "verified\|falsified\|processing time" case-studies/
	-grep -iR "warning\|error" case-studies/

###############################################################################
## Developer specific targets (some out of date)
###############################################################################

# outdated targets
