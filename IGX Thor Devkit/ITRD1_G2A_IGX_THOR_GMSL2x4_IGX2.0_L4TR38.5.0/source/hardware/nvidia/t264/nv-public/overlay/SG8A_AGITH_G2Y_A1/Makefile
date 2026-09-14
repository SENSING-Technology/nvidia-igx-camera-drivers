# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t264/nv-public/overlay/SG8A_AGITH_G2Y_A1

# ifdef SG8A_AGITH_G2Y_A1
# ifdef SGCAM_GMSL2
	dtbo-y += sgcam/tegra264-camera-sgcam-s56cx1-shf3lx2-overlay.dtbo
	dtbo-y += sgcam/tegra264-camera-sgcam-s56cx1-shw5gx2-overlay.dtbo
# endif
# endif

ifneq ($(dtb-y),)
dtb-y := $(addprefix $(makefile-path)/,$(dtb-y))
endif
ifneq ($(dtbo-y),)
dtbo-y := $(addprefix $(makefile-path)/,$(dtbo-y))
endif

dtb-y += $(old-dtb)
dtbo-y += $(old-dtbo)
