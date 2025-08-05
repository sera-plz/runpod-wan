## Downloading loras:

note: if civitai requires token, set it like so:
```bash
token=YOUR_TOKEN
```
LORAs:
```bash
# lightx2v i2v self-forcing
aria2c -x16 -s16 -d /workspace/models/loras -o lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors

# WAN22 lightx2v high
aria2c -x16 -s16 -d /workspace/models/loras -o Wan2.2-Lightning_T2V-A14B-4steps-lora_HIGH_fp16.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan22-Lightning/Wan2.2-Lightning_T2V-A14B-4steps-lora_HIGH_fp16.safetensors
# WAN22 lightx2v low
aria2c -x16 -s16 -d /workspace/models/loras -o Wan2.2-Lightning_T2V-A14B-4steps-lora_LOW_fp16.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan22-Lightning/Wan2.2-Lightning_T2V-A14B-4steps-lora_LOW_fp16.safetensors

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