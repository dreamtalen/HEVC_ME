# HEVC_ME

3.31日更新

目前进展：完成参考帧缓存(ref_mem，附属有bank.v，shift移位模块等等)、参考帧缓存控制（ref_mem_ctrl）、PE阵列(PE_array)、PE阵列控制(PE_array_ctrl)
SAD加法树、第一层搜索算法的top模块(basic_layer_search)

目前需求只需要算出正确的sad值，不需要计算出运动向量（cost函数未定）
