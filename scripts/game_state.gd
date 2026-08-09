extends RefCounted
class_name GameState

const SAVE_PATH := "user://neon_forge_save.json"
const SAVE_VERSION := 3
var data := {}

func default_data()->Dictionary:
    return {
        "version":SAVE_VERSION,"credits":50.0,"energy":0.0,"research":0.0,"cores":0,"event_chips":0,
        "last_seen":Time.get_unix_time_from_system(),"playtime":0.0,"total_earned":0.0,"highest_cps":0.0,"manual_taps":0,
        "prestiges":0,"upgrades":{},"zones_unlocked":1,"collectibles":[],"achievements":{},"quests":{},
        "daily_day":0,"daily_last_claim":"","settings":{"language":"de","sound":true,"music":true,"vibration":true,"reduce_motion":false},
        "event_progress":0.0,"event_claims":[],"tutorial_step":0,"secrets":[]
    }

func load_game()->Dictionary:
    data=default_data()
    if FileAccess.file_exists(SAVE_PATH):
        var f=FileAccess.open(SAVE_PATH,FileAccess.READ)
        var parsed=JSON.parse_string(f.get_as_text())
        if typeof(parsed)==TYPE_DICTIONARY:
            _merge(data,parsed)
            _migrate()
    return data

func save_game():
    data["last_seen"]=Time.get_unix_time_from_system()
    var f=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    f.store_string(JSON.stringify(data))

func reset():
    if FileAccess.file_exists(SAVE_PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    data=default_data()
    save_game()

func _merge(dst:Dictionary,src:Dictionary):
    for k in src:
        if dst.has(k) and typeof(dst[k])==TYPE_DICTIONARY and typeof(src[k])==TYPE_DICTIONARY: _merge(dst[k],src[k])
        else: dst[k]=src[k]

func _migrate():
    data["version"]=SAVE_VERSION
