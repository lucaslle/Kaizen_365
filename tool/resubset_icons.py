# Flutter's icon tree shaking corrupts the gvar table of the variable Material Symbols font,
# so most icons render blank on the web. Redo the subset with fonttools, keeping the same icons.
import json
from pathlib import Path
from urllib.parse import urlparse

from fontTools import subset
from fontTools.ttLib import TTFont

FONT = 'lib/fonts/MaterialSymbolsRounded.ttf'

config = json.loads(Path('.dart_tool/package_config.json').read_text())
package = next(p for p in config['packages'] if p['name'] == 'material_symbols_icons')
source = Path(urlparse(package['rootUri']).path) / FONT
shaken = Path('build/web/assets/packages/material_symbols_icons') / FONT

options = subset.Options()
font = subset.load_font(str(source), options)
subsetter = subset.Subsetter(options)
subsetter.populate(unicodes=list(TTFont(shaken).getBestCmap()))
subsetter.subset(font)
subset.save_font(font, str(shaken), options)

check = TTFont(shaken)
for name in check.getGlyphOrder():
    check['gvar'].variations[name]
