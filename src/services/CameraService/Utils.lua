local CameraServiceUtils = {}

CameraServiceUtils.settings = {
    zoom_settings = {
        default_zoom_distance = 10,
        zoom_step = 1,
        min_zoom_distance = 0.5,
        max_zoom_distance = 50,
    },
}

CameraServiceUtils.enums = {
    CameraCollisionMode = {
        None = 0,
        GhostWalls = 1,
        Zoom = 2,
    },
    CameraStyle = {
        Classic = 0,
        Zomboid = 1,
    },
}

return CameraServiceUtils