extends RefCounted
class_name UUID

static func new_uuid_string() -> String:
    var chars := "0123456789abcdef"
    var sections := [8, 4, 4, 4, 12]
    var parts: Array[String] = []
    for length in sections:
        var part := ""
        for i in range(length):
            part += chars[RNG.randi() % chars.length()]
        parts.append(part)
    var result: String = ""
    for i in range(parts.size()):
        if i > 0:
            result += "-"
        result += parts[i]
    return result

