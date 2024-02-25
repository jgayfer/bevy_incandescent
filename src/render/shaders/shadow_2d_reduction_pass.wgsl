#import bevy_incandescent::shadow_2d_types::ShadowMapMeta;

@group(0) @binding(0)
var source_shadow_map: texture_storage_2d_array<rg32float, read_write>;

@group(0) @binding(1)
var dest_shadow_map: texture_storage_2d_array<rg32float, read_write>;

@group(0) @binding(2)
var<uniform> shadow_map_meta: ShadowMapMeta;

@group(0) @binding(3)
var<uniform> reduction_time: u32;

@compute @workgroup_size(16, 16, 1)
fn main(@builtin(global_invocation_id) invocation_id: vec3u) {
    let px = invocation_id.xy;
    let size = shadow_map_meta.size;
    let light_index = invocation_id.z;

    if px.x >= size >> (reduction_time - 1u) || px.y >= size {
        return;
    }

    let color = min(
        textureLoad(source_shadow_map, px, light_index),
        textureLoad(source_shadow_map, vec2u(px.x + 1, px.y), light_index),
    );

    textureStore(
        dest_shadow_map,
        vec2u(px.x >> reduction_time, px.y),
        light_index,
        color,
    );
}
