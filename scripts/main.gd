extends Control

const LocalizationCls = preload("res://scripts/localization.gd")
const StateCls = preload("res://scripts/game_state.gd")
const ContentCls = preload("res://scripts/game_content.gd")

var L
var S
var C
var D: Dictionary
var upgrades: Array = []
var collectibles: Array = []
var achievements: Array = []
var quests: Array = []
var page := "city"
var page_box: VBoxContainer
var credits_label: Label
var cps_label: Label
var resource_row: HBoxContainer
var toast_layer: VBoxContainer
var save_timer := 0.0
var offline_reward := 0.0

func _ready() -> void:
    L = LocalizationCls.new()
    S = StateCls.new()
    C = ContentCls.new()
    D = S.load_game()
    S.data = D
    L.set_language(str(D["settings"]["language"]))
    upgrades = C.upgrades()
    collectibles = C.collectibles()
    achievements = C.achievements()
    quests = C.quests()
    _apply_offline()
    _build_ui()
    _refresh_all()
    _show_tutorial_if_needed()

func _process(delta: float) -> void:
    D["playtime"] = float(D["playtime"]) + delta
    save_timer += delta
    var cps := _cps()
    if cps > 0.0:
        var gain := cps * delta
        D["credits"] = float(D["credits"]) + gain
        D["total_earned"] = float(D["total_earned"]) + gain
        D["event_progress"] = float(D["event_progress"]) + gain
        D["highest_cps"] = max(float(D["highest_cps"]), cps)
    if save_timer >= 10.0:
        save_timer = 0.0
        S.save_game()
    if is_instance_valid(credits_label):
        credits_label.text = _money(float(D["credits"]))
    if is_instance_valid(cps_label):
        cps_label.text = _money(cps) + " " + L.t("per_sec")

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
        if S != null:
            S.save_game()

func _apply_offline() -> void:
    var now := Time.get_unix_time_from_system()
    var elapsed := clamp(now - float(D["last_seen"]), 0.0, 8.0 * 3600.0)
    offline_reward = _cps() * elapsed * 0.75
    if offline_reward > 1.0:
        D["credits"] = float(D["credits"]) + offline_reward
        D["total_earned"] = float(D["total_earned"]) + offline_reward
    D["last_seen"] = now

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("07101f")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var safe := MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 18)
    safe.add_theme_constant_override("margin_right", 18)
    safe.add_theme_constant_override("margin_top", 22)
    safe.add_theme_constant_override("margin_bottom", 16)
    add_child(safe)

    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 12)
    safe.add_child(root)

    var title := Label.new()
    title.text = L.t("game_title") + "  //  " + L.t("subtitle")
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color("4de8ff"))
    root.add_child(title)

    resource_row = HBoxContainer.new()
    resource_row.add_theme_constant_override("separation", 8)
    root.add_child(resource_row)
    _build_resources()

    var production_panel := PanelContainer.new()
    production_panel.custom_minimum_size = Vector2(0, 150)
    root.add_child(production_panel)
    var production_box := VBoxContainer.new()
    production_box.alignment = BoxContainer.ALIGNMENT_CENTER
    production_panel.add_child(production_box)

    credits_label = Label.new()
    credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    credits_label.add_theme_font_size_override("font_size", 34)
    production_box.add_child(credits_label)

    cps_label = Label.new()
    cps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cps_label.add_theme_color_override("font_color", Color("88a8c9"))
    production_box.add_child(cps_label)

    var tap := Button.new()
    tap.text = "⚡ " + L.t("produce") + "  +" + str(int(_tap_value()))
    tap.custom_minimum_size = Vector2(0, 58)
    tap.pressed.connect(_tap)
    production_box.add_child(tap)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(scroll)
    page_box = VBoxContainer.new()
    page_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page_box.add_theme_constant_override("separation", 9)
    scroll.add_child(page_box)

    var nav := HBoxContainer.new()
    nav.add_theme_constant_override("separation", 4)
    root.add_child(nav)
    var nav_items := [
        ["city", "🏙 " + L.t("city")],
        ["upgrade", "⬆ " + L.t("upgrade")],
        ["quests", "✓ " + L.t("quests")],
        ["collection", "◆ " + L.t("collection")],
        ["more", "⋯ " + L.t("more")]
    ]
    for item in nav_items:
        var button := Button.new()
        button.text = str(item[1])
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.custom_minimum_size = Vector2(0, 56)
        button.pressed.connect(_switch_page.bind(str(item[0])))
        nav.add_child(button)

    toast_layer = VBoxContainer.new()
    toast_layer.set_anchors_preset(Control.PRESET_TOP_WIDE)
    toast_layer.offset_left = 30
    toast_layer.offset_right = -30
    toast_layer.offset_top = 70
    add_child(toast_layer)

    if offline_reward > 1.0:
        call_deferred("_modal", L.t("offline"), L.t("offline_body") % _money(offline_reward), false)

func _build_resources() -> void:
    if not is_instance_valid(resource_row):
        return
    for child in resource_row.get_children():
        child.queue_free()
    var values := [
        ["⚙", L.t("energy"), "energy"],
        ["⌬", L.t("research"), "research"],
        ["◈", L.t("cores"), "cores"]
    ]
    for item in values:
        var panel := PanelContainer.new()
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var label := Label.new()
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.text = str(item[0]) + " " + str(item[1]) + "\n" + _money(float(D[str(item[2])]))
        panel.add_child(label)
        resource_row.add_child(panel)

func _switch_page(next_page: String) -> void:
    page = next_page
    _render_page()

func _refresh_all() -> void:
    _build_resources()
    _render_page()

func _render_page() -> void:
    if not is_instance_valid(page_box):
        return
    for child in page_box.get_children():
        child.queue_free()
    match page:
        "city":
            _page_city()
        "upgrade":
            _page_upgrades()
        "quests":
            _page_quests()
        "collection":
            _page_collection()
        "more":
            _page_more()

func _head(text: String) -> void:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 22)
    label.add_theme_color_override("font_color", Color("4de8ff"))
    page_box.add_child(label)

func _card(title: String, body: String, button_text := "", action := Callable()) -> void:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(0, 90)
    page_box.add_child(panel)
    var box := VBoxContainer.new()
    panel.add_child(box)
    var heading := Label.new()
    heading.text = title
    heading.add_theme_font_size_override("font_size", 18)
    box.add_child(heading)
    var description := Label.new()
    description.text = body
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.add_theme_color_override("font_color", Color("9fb4cc"))
    box.add_child(description)
    if button_text != "":
        var button := Button.new()
        button.text = button_text
        button.custom_minimum_size = Vector2(0, 44)
        button.disabled = not action.is_valid()
        if action.is_valid():
            button.pressed.connect(action)
        box.add_child(button)

func _page_city() -> void:
    _head("🏙 " + L.t("city"))
    for i in range(C.zones.size()):
        var zone: Dictionary = C.zones[i]
        var unlocked := i < int(D["zones_unlocked"])
        var body: String
        if unlocked:
            body = L.t("production") + ": " + _money(float(zone["base"]) * _zone_multiplier(i)) + "/s"
        else:
            body = L.t("locked") + " • " + L.t("cost") + ": " + _money(float(zone["unlock"]))
        var button_text := ""
        var action := Callable()
        if not unlocked and i == int(D["zones_unlocked"]):
            button_text = L.t("buy") + " " + _money(float(zone["unlock"]))
            action = _unlock_zone.bind(i)
        _card(("✓ " if unlocked else "🔒 ") + str(zone["name"]), body, button_text, action)

func _page_upgrades() -> void:
    _head("⬆ " + L.t("upgrade"))
    for upgrade in upgrades:
        if int(upgrade["zone"]) >= int(D["zones_unlocked"]):
            continue
        var level := int(D["upgrades"].get(upgrade["id"], 0))
        var cost := _upgrade_cost(upgrade, level)
        var body := L.t("bonus") + ": +" + str(int(float(upgrade["power"]) * 100.0)) + "% • " + L.t("cost") + ": " + _money(cost)
        var label := str(upgrade["name"]) + "  Lv." + str(level)
        _card(label, body, L.t("buy"), _buy_upgrade.bind(upgrade))

func _page_quests() -> void:
    _head("✓ " + L.t("quests"))
    for quest in quests:
        if bool(D["quests"].get(quest["id"], false)):
            continue
        var progress := _progress_for(str(quest["type"]))
        var done := progress >= float(quest["target"])
        var body := _money(progress) + " / " + _money(float(quest["target"])) + " • " + L.t("reward") + ": " + _money(float(quest["reward"]))
        var action := Callable()
        if done:
            action = _claim_quest.bind(quest)
        _card(str(quest["name"]), body, L.t("claim") if done else L.t("locked"), action)

    _head("🏆 " + L.t("achievements"))
    var shown := 0
    for achievement in achievements:
        if shown >= 12:
            break
        var done := bool(D["achievements"].get(achievement["id"], false))
        if bool(achievement["secret"]) and not done:
            continue
        var progress := _progress_for(str(achievement["type"]))
        _card(("✓ " if done else "○ ") + str(achievement["name"]), _money(progress) + " / " + _money(float(achievement["target"])) + " • +" + str(achievement["reward"]) + " Forschung")
        shown += 1

func _page_collection() -> void:
    _head("◆ " + L.t("collection") + "  " + str(D["collectibles"].size()) + "/" + str(collectibles.size()))
    for collectible in collectibles:
        var owned := collectible["id"] in D["collectibles"]
        var details := "???"
        if owned:
            details = "+%.1f%% global" % (float(collectible["bonus"]) * 100.0)
        _card(("◆ " if owned else "◇ ") + str(collectible["name"]), str(collectible["rarity"]) + " • " + details)

func _page_more() -> void:
    _head("◈ " + L.t("prestige"))
    var cores := _prestige_gain()
    var prestige_action := Callable()
    if cores > 0:
        prestige_action = _prestige
    _card(L.t("prestige_ready") if cores > 0 else L.t("prestige"), L.t("rebirth_hint") + "\n+" + str(cores) + " " + L.t("cores"), L.t("rebirth") if cores > 0 else L.t("locked"), prestige_action)

    _head("🎁 " + L.t("daily"))
    var can_claim := _can_daily()
    var daily_action := Callable()
    if can_claim:
        daily_action = _claim_daily
    _card("Day " + str(int(D["daily_day"]) + 1), "Credits + Research + Collectable chance", L.t("claim") if can_claim else L.t("claimed"), daily_action)

    _head("⚡ " + L.t("events"))
    _card(L.t("event_title"), L.t("event_desc") + "\nChips: " + str(int(D["event_chips"])) + " • Progress: " + _money(float(D["event_progress"])), "Exchange 10K → 1 Chip", _event_exchange)

    _head("📊 " + L.t("stats"))
    var stats_text := L.t("playtime") + ": " + _duration(float(D["playtime"])) + "\n"
    stats_text += L.t("total_earned") + ": " + _money(float(D["total_earned"])) + "\n"
    stats_text += L.t("highest_cps") + ": " + _money(float(D["highest_cps"])) + "\n"
    stats_text += L.t("prestiges") + ": " + str(D["prestiges"])
    _card(L.t("stats"), stats_text)

    _head("⚙ " + L.t("settings"))
    var language := OptionButton.new()
    var languages := [["Deutsch", "de"], ["English", "en"], ["Français", "fr"], ["Español", "es"], ["Italiano", "it"], ["Português", "pt"]]
    for item in languages:
        language.add_item(str(item[0]))
        var idx := language.item_count - 1
        language.set_item_metadata(idx, str(item[1]))
        if str(item[1]) == str(D["settings"]["language"]):
            language.select(idx)
    language.item_selected.connect(_language_changed.bind(language))
    page_box.add_child(language)

    for key in ["sound", "music", "vibration", "reduce_motion"]:
        var check := CheckButton.new()
        check.text = L.t(str(key))
        check.button_pressed = bool(D["settings"][key])
        check.toggled.connect(_setting_changed.bind(str(key)))
        page_box.add_child(check)

    var reset := Button.new()
    reset.text = "⚠ " + L.t("reset")
    reset.pressed.connect(_confirm_reset)
    page_box.add_child(reset)

func _tap() -> void:
    var gain := _tap_value()
    D["credits"] = float(D["credits"]) + gain
    D["total_earned"] = float(D["total_earned"]) + gain
    D["manual_taps"] = int(D["manual_taps"]) + 1
    D["energy"] = float(D["energy"]) + 0.2
    D["research"] = float(D["research"]) + 0.05
    _roll_collectible(0.015)
    _check_achievements()
    _refresh_all()

func _tap_value() -> float:
    return 5.0 * (1.0 + float(D["cores"]) * 0.08) * _collection_mult()

func _cps() -> float:
    if C == null or D == null:
        return 0.0
    var total := 0.0
    for i in range(int(D.get("zones_unlocked", 1))):
        total += float(C.zones[i]["base"]) * _zone_multiplier(i)
    return total * (1.0 + float(D.get("cores", 0)) * 0.10) * _collection_mult()

func _zone_multiplier(zone: int) -> float:
    var multiplier := 1.0
    if upgrades.is_empty():
        return multiplier
    for upgrade in upgrades:
        if int(upgrade["zone"]) == zone:
            var level := int(D["upgrades"].get(upgrade["id"], 0))
            multiplier *= 1.0 + float(upgrade["power"]) * level
    return multiplier

func _collection_mult() -> float:
    if collectibles.is_empty():
        return 1.0
    var bonus := 0.0
    for collectible in collectibles:
        if collectible["id"] in D.get("collectibles", []):
            bonus += float(collectible["bonus"])
    return 1.0 + bonus

func _upgrade_cost(upgrade: Dictionary, level: int) -> float:
    return float(upgrade["base_cost"]) * pow(1.38, level)

func _buy_upgrade(upgrade: Dictionary) -> void:
    var level := int(D["upgrades"].get(upgrade["id"], 0))
    var cost := _upgrade_cost(upgrade, level)
    if level < int(upgrade["max"]) and float(D["credits"]) >= cost:
        D["credits"] = float(D["credits"]) - cost
        D["upgrades"][upgrade["id"]] = level + 1
        D["research"] = float(D["research"]) + 1.0 + level * 0.2
        _roll_collectible(0.05)
        _check_achievements()
        S.save_game()
        _refresh_all()

func _unlock_zone(index: int) -> void:
    var cost := float(C.zones[index]["unlock"])
    if float(D["credits"]) >= cost:
        D["credits"] = float(D["credits"]) - cost
        D["zones_unlocked"] = index + 1
        D["research"] = float(D["research"]) + 25.0 * index
        _toast(L.t("new_unlock") + ": " + str(C.zones[index]["name"]))
        _check_achievements()
        _refresh_all()

func _progress_for(kind: String) -> float:
    match kind:
        "earn":
            return float(D["total_earned"])
        "tap":
            return float(D["manual_taps"])
        "upgrade":
            var total := 0
            for value in D["upgrades"].values():
                total += int(value)
            return float(total)
        "collect":
            return float(D["collectibles"].size())
        "prestige":
            return float(D["prestiges"])
        "zone":
            return float(D["zones_unlocked"])
    return 0.0

func _claim_quest(quest: Dictionary) -> void:
    if _progress_for(str(quest["type"])) >= float(quest["target"]) and not bool(D["quests"].get(quest["id"], false)):
        D["quests"][quest["id"]] = true
        D["credits"] = float(D["credits"]) + float(quest["reward"])
        D["research"] = float(D["research"]) + float(quest["reward"]) * 0.02
        _toast(L.t("mission_complete"))
        _refresh_all()

func _check_achievements() -> void:
    for achievement in achievements:
        if not bool(D["achievements"].get(achievement["id"], false)) and _progress_for(str(achievement["type"])) >= float(achievement["target"]):
            D["achievements"][achievement["id"]] = true
            D["research"] = float(D["research"]) + float(achievement["reward"])
            _toast("🏆 " + str(achievement["name"]))

func _roll_collectible(chance: float) -> void:
    if randf() > chance or D["collectibles"].size() >= collectibles.size():
        return
    var pool: Array = []
    for collectible in collectibles:
        if not collectible["id"] in D["collectibles"]:
            pool.append(collectible)
    if pool.is_empty():
        return
    var collectible: Dictionary = pool[randi() % pool.size()]
    D["collectibles"].append(collectible["id"])
    _toast(L.t("collect_found") + " " + str(collectible["name"]))

func _prestige_gain() -> int:
    return max(0, int(floor(sqrt(float(D["total_earned"]) / 1000000.0))))

func _prestige() -> void:
    var gain := _prestige_gain()
    if gain <= 0:
        return
    var settings = D["settings"].duplicate(true)
    var owned_collectibles = D["collectibles"].duplicate()
    var owned_achievements = D["achievements"].duplicate(true)
    var prestige_count := int(D["prestiges"]) + 1
    var permanent_cores := int(D["cores"]) + gain
    D = S.default_data()
    S.data = D
    D["settings"] = settings
    D["collectibles"] = owned_collectibles
    D["achievements"] = owned_achievements
    D["prestiges"] = prestige_count
    D["cores"] = permanent_cores
    S.save_game()
    _toast("◈ +" + str(gain) + " " + L.t("cores"))
    _refresh_all()

func _can_daily() -> bool:
    return str(D["daily_last_claim"]) != Time.get_date_string_from_system()

func _claim_daily() -> void:
    if not _can_daily():
        return
    D["daily_last_claim"] = Time.get_date_string_from_system()
    D["daily_day"] = (int(D["daily_day"]) + 1) % 7
    var day := int(D["daily_day"]) + 1
    D["credits"] = float(D["credits"]) + 500.0 * pow(4.0, day)
    D["research"] = float(D["research"]) + 10.0 * day
    if day in [3, 7]:
        _roll_collectible(1.0)
    S.save_game()
    _refresh_all()

func _event_exchange() -> void:
    if float(D["event_progress"]) >= 10000.0:
        D["event_progress"] = float(D["event_progress"]) - 10000.0
        D["event_chips"] = int(D["event_chips"]) + 1
        _refresh_all()

func _language_changed(index: int, select: OptionButton) -> void:
    D["settings"]["language"] = str(select.get_item_metadata(index))
    L.set_language(str(D["settings"]["language"]))
    S.save_game()
    _rebuild()

func _setting_changed(enabled: bool, key: String) -> void:
    D["settings"][key] = enabled
    S.save_game()

func _confirm_reset() -> void:
    _modal(L.t("reset"), L.t("reset_confirm"), true)

func _rebuild() -> void:
    for child in get_children():
        child.queue_free()
    call_deferred("_build_ui")
    call_deferred("_refresh_all")

func _modal(title_text: String, body_text: String, danger := false) -> void:
    var dialog := ConfirmationDialog.new()
    dialog.title = title_text
    dialog.dialog_text = body_text
    dialog.ok_button_text = L.t("yes_reset") if danger else L.t("ok")
    dialog.cancel_button_text = L.t("cancel")
    if danger:
        dialog.confirmed.connect(_do_reset)
    add_child(dialog)
    dialog.popup_centered(Vector2i(560, 260))

func _do_reset() -> void:
    S.reset()
    D = S.data
    L.set_language(str(D["settings"]["language"]))
    _rebuild()

func _toast(text: String) -> void:
    if not is_instance_valid(toast_layer):
        return
    var panel := PanelContainer.new()
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 17)
    panel.add_child(label)
    toast_layer.add_child(panel)
    get_tree().create_timer(2.2).timeout.connect(panel.queue_free)

func _show_tutorial_if_needed() -> void:
    if int(D["tutorial_step"]) == 0:
        D["tutorial_step"] = 1
        S.save_game()
        call_deferred("_modal", "Willkommen in Neon Forge", "Tippe auf PRODUZIEREN, kaufe Upgrades und automatisiere deine Stadt. Neue Systeme öffnen sich mit deinem Fortschritt.", false)

func _money(value: float) -> String:
    var magnitude := abs(value)
    if magnitude < 1000.0:
        return str(int(value))
    var units := ["K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
    var scaled := magnitude
    var unit_index := -1
    while scaled >= 1000.0 and unit_index < units.size() - 1:
        scaled /= 1000.0
        unit_index += 1
    return "%.2f%s" % [scaled, units[unit_index]]

func _duration(seconds: float) -> String:
    return "%02dh %02dm" % [int(seconds) / 3600, (int(seconds) % 3600) / 60]
