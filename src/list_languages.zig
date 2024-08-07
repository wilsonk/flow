const syntax = @import("syntax");

pub fn list(writer: anytype) !void {
    var max_language_len: usize = 0;
    var max_langserver_len: usize = 0;
    var max_formatter_len: usize = 0;
    var max_extensions_len: usize = 0;

    for (syntax.FileType.file_types) |file_type| {
        max_language_len = @max(max_language_len, file_type.name.len);
        max_langserver_len = @max(max_langserver_len, args_string_length(file_type.language_server));
        max_formatter_len = @max(max_formatter_len, args_string_length(file_type.formatter));
        max_extensions_len = @max(max_extensions_len, args_string_length(file_type.extensions));
    }

    try write_string(writer, "Language", max_language_len + 1);
    try write_string(writer, "Extensions", max_extensions_len + 1);
    try write_string(writer, "Language Server", max_langserver_len + 1);
    try write_string(writer, "Formatter", max_formatter_len);
    try writer.writeAll("\n");

    for (syntax.FileType.file_types) |file_type| {
        try write_string(writer, file_type.name, max_language_len + 1);
        try write_segmented(writer, file_type.extensions, ",", max_extensions_len + 1);
        try write_segmented(writer, file_type.language_server, " ", max_langserver_len + 1);
        try write_segmented(writer, file_type.formatter, " ", max_formatter_len);
        try writer.writeAll("\n");
    }
}

fn args_string_length(args_: ?[]const []const u8) usize {
    const args = args_ orelse return 0;
    var len: usize = 0;
    var first: bool = true;
    for (args) |arg| {
        if (first) first = false else len += 1;
        len += arg.len;
    }
    return len;
}

fn write_string(writer: anytype, string: []const u8, pad: usize) !void {
    try writer.writeAll(string);
    try write_padding(writer, string.len, pad);
}

fn write_segmented(writer: anytype, args_: ?[]const []const u8, sep: []const u8, pad: usize) !void {
    const args = args_ orelse return;
    var len: usize = 0;
    var first: bool = true;
    for (args) |arg| {
        if (first) first = false else {
            len += 1;
            try writer.writeAll(sep);
        }
        len += arg.len;
        try writer.writeAll(arg);
    }
    try write_padding(writer, len, pad);
}

fn write_padding(writer: anytype, len: usize, pad_len: usize) !void {
    for (0..pad_len - len) |_| try writer.writeAll(" ");
}

