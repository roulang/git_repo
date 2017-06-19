function getRandom(base, scope, dir) {
	var n;
	switch (dir) {
		case -1:
			n = Math.round(Math.random() * scope + 0.5);
			n = base - n;
			break;
		case 1:
			n = Math.round(Math.random() * scope + 0.5);
			n = base + n;
			break;
		default:
			n = Math.round((Math.random() - 0.5) * scope * 2);
			n = base + n;
	}
	return n;
};

function toFixedLength(input, length, padding) {
    padding = String(padding || "0");
    return (padding.repeat(length) + input).slice(-length);
}
