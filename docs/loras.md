## Downloading loras:

note: if civitai requires token, set it like so:
```bash
token=YOUR_TOKEN
```
LORAs:
```bash
# lightx2v self-forcing
aria2c -x16 -s16 -d /workspace/models/loras -o Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors

# CausVid Lora
aria2c -x16 -s16 -d /workspace/models/loras -o Wan21_CausVid_14B_T2V_lora_rank32.safetensors --continue=true https://civitai.com/api/download/models/1794316?type=Model&format=SafeTensor

aria2c -x16 -s16 -d /workspace/models/loras -o Wan21_CausVid_14B_T2V_lora_rank32_v2.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_CausVid_14B_T2V_lora_rank32_v2.safetensors

# AccVid lora
aria2c -x16 -s16 -d /workspace/models/loras -o Wan21_AccVid_T2V_14B_lora_rank32_fp16.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_AccVid_T2V_14B_lora_rank32_fp16.safetensors

# WAN-Fun reward lora
aria2c -x16 -s16 -d /workspace/models/loras -o Wan2.1-Fun-14B-InP-MPS.safetensors --continue=true https://huggingface.co/alibaba-pai/Wan2.1-Fun-Reward-LoRAs/resolve/main/Wan2.1-Fun-14B-InP-MPS.safetensors

# cinematic zoom
aria2c -x16 -s16 -d /workspace/models/loras -o Su_MCraft_Ep60.safetensors --continue=true "https://civitai.com/api/download/models/1599906?type=Model&format=SafeTensor&token=${token}"
# trigger words:
# cinematic camera pan
# cinematic camera zoom in
# cinematic camera zoom out

# phut hon dance
aria2c -x16 -s16 -d /workspace/models/loras -o dbc.safetensors --continue=true "https://civitai.com/api/download/models/1542806?type=Model&format=SafeTensor&token=${token}"
# trigger words: 
# dabaichui
# making dabaichui motion
# example:  dabaichui，someone holds someone's head with both hands and twists someone's waist and hips left and right ，making dabaichui motion

# super saiyan:
aria2c -x16 -s16 -d /workspace/models/loras -o super_saiyan_35_epochs.safetensors --continue=true "https://civitai.com/api/download/models/1554033?type=Model&format=SafeTensor&token=${token}"
# trigger words:
# 5up3r super saiyan transformation
# examples:
# A South Asian man with dark hair and a beard clenches his fists, staring forward. His hair brightens to glowing yellow, spiking up as gold energy surges around his body. The background pulses with yellow light, and sparks crackle in the air during his 5up3r super saiyan transformation, real life style.
# A man with curly dark hair and a beard clenches his fists, staring forward. His hair brightens to glowing yellow, spiking up as gold energy surges around his body. The background pulses with yellow light, and sparks crackle in the air during his 5up3r super saiyan transformation, real life style.
# Pepe the Frog clenches his fists, staring forward. Pepe the frog's hair brightens to glowing yellow, spiking up as gold energy surges around Pepe the frog's body. The background pulses with yellow light, and sparks crackle in the air during his 5up3r super saiyan transformation, real life style.

# Hulk transformation:
aria2c -x16 -s16 -d /workspace/models/loras -o Hulk_epoch35.safetensors --continue=true "https://civitai.com/api/download/models/1588339?type=Model&format=SafeTensor&token=${token}"
# trigger words: 
# h01k green hulk transformation
# examples:
# The video shows a man looking forward. Slowly, the h01k green hulk transformation begins. His muscles start to swell, veins bulge beneath his skin, and his face tightens with strain. His skin gradually shifts to green as his body continues to grow. His clothes begin to tear apart under the pressure. The transformation completes as the Hulk emerges, standing tall and roaring.
# The video shows an Asian man looking forward. Slowly, the h01k green hulk transformation begins. His muscles start to swell, veins bulge beneath his skin, and his face tightens with strain. His skin gradually shifts to green as his body continues to grow. His clothes begin to tear apart under the pressure. The transformation completes as the Hulk emerges, standing tall and roaring.
# The video shows an elderly man looking forward. Slowly, the h01k green hulk transformation begins. His muscles start to swell, veins bulge beneath his skin, and his face tightens with strain. His skin gradually shifts to green as his body continues to grow. His clothes begin to tear apart under the pressure. The transformation completes as the Hulk emerges, standing tall and roaring

```