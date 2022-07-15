<template>
	<div class="container">
		<HelpModal v-model:active="helpModalActive" />
		<CartoucheModal
			:baseWord="cartoucheModalBaseWord"
			:glyphs="cartoucheModalGlyphs"
			v-model:active="cartoucheModalActive"
			@submit="cartoucheModalSubmitted($event)"
		/>
		<LongPiModal
			:piece="longPiModalPiece"
			v-model:active="longPiModalActive"
			@submit="longPiModalSubmitted($event)"
		/>

		<header>
			<span>ilo lili pi sitelen pona</span>
			<a href="#" @click="helpModalActive = true">ni li seme?</a>
		</header>

		<div class="input-box z-depth-2 blue lighten-4">
			<div class="input-field">
				<label for="sitelen-lasina">o pana e sitelen Lasina</label>
				<textarea v-model="text" class="materialize-textarea" id="sitelen-lasina" />
			</div>
		</div>

		<div class="options z-depth-2 green lighten-4">
			<div class="input-field">
				<select v-model="font">
					<optgroup label="nasin Ligature">
						<option value="linja-sike">linja sike</option>
					</optgroup>
					<optgroup label="nasin UCSUR">
						<option value="nasin-nanpa">nasin nanpa</option>
						<option value="sitelen-kiwen-seli-juniko">sitelen kiwen seli juniko</option>
					</optgroup>
				</select>
			</div>
			<label>
				<input type="checkbox" v-model="useLongPi" />
				<span>o kepeken nimi "pi" suli: <span class="sitelen-pona">jan pi+__pana__sona</span></span>
			</label>
			<label v-if="fontSupportsFancyXAlaX">
				<input type="checkbox" v-model="useFancyXAlaX" />
				<span>o kepeken nasin "X ala X" suwi: <span class="sitelen-pona">__pali&lt;ala&gt;__pali</span></span>
			</label>
			<label v-if="fontSupportsGlyphExtensions">
				<input type="checkbox" v-model="useManualGlyphExtensions" />
				<span>o suli e sitelen mute: <code>kepeken{ilo ni}</code> → <span class="sitelen-pona">kepeken>__ilo__ni</span></span>
			</label>
		</div>

		<PieceRenderer
			v-if="font === 'linja-sike'"
			class="monospace"
			:pieces="renderedLinjaSike"
			@name="openCartoucheModal($event)"
			@pi="openLongPiModal($event)"
		/>

		<PieceRenderer
			v-if="font === 'linja-sike'"
			class="sitelen-pona-suli"
			:pieces="renderedLinjaSike"
			@name="openCartoucheModal($event)"
			@pi="openLongPiModal($event)"
		/>

		<PieceRenderer
			v-if="font === 'nasin-nanpa'"
			class="sitelen-pona-ucsur-suli"
			:pieces="renderedUCSUR"
			@name="openCartoucheModal($event)"
			@pi="openLongPiModal($event)"
		/>

		<PieceRenderer
			v-if="font === 'sitelen-kiwen-seli-juniko'"
			class="sitelen-pona-ssk-suli"
			:pieces="renderedUCSUR"
			@name="openCartoucheModal($event)"
			@pi="openLongPiModal($event)"
		/>
	</div>
</template>

<script>
import M from 'materialize-css';
import TinyLex from 'tinylex';

import PieceRenderer from './components/PieceRenderer.vue';
import HelpModal from './components/HelpModal.vue';
import CartoucheModal from './components/CartoucheModal.vue';
import LongPiModal from './components/LongPiModal.vue';

import presetCartouches from './presetCartouches.json';
import ucsur from './ucsur.json';

const terminatingParticles = new Set(["anu", "e", "en", "la", "li", "o", "pi"]);
const preps = new Set(["tawa", "tan", "lon", "kepeken", "sama"]);

// Some UCSUR characters
const zeroWidthSpace = '\u200B';
const zeroWidthJoiner = '\u200D';
const startCartouche = String.fromCodePoint(0xF1990);
const continueCartouche = String.fromCodePoint(0xF1992);
const endCartouche = String.fromCodePoint(0xF1991);
const startLongGlyph = String.fromCodePoint(0xF1997);
const endLongGlyph = String.fromCodePoint(0xF1998);
const startReverseLongGlyph = String.fromCodePoint(0xF199A);
const endReverseLongGlyph = String.fromCodePoint(0xF199B);
const spMidDot = String.fromCodePoint(0xF199C);
const spColon = String.fromCodePoint(0xF199D);
const stackingJoiner = String.fromCodePoint(0xF1995);
const scalingJoiner = String.fromCodePoint(0xF1996);

const manualGlyphExtensionTokenTypes = [
	[/^{(([\w\-+`]|[^\S\r\n])+}[a-z]+{([\w\-+`]|[^\S\r\n])+)}/, 'MANUAL_GLYPH_EXTENSION_LR'],
	[/^{(([\w\-+`]|[^\S\r\n])+}[a-z]+)/, 'MANUAL_GLYPH_EXTENSION_L'],
	[/^([a-z]+{([\w\-+`]|[^\S\r\n])+)}/, 'MANUAL_GLYPH_EXTENSION_R']
];

const tokenTypes = [
	[/^@{([^}]*)}/, 'VERBATIM'],
	[/^\[([^_\n\]]*)\]/, 'MANUAL_CARTOUCHE'],
	[/^([a-z][\w\-+`]*)/, 'WORD'],
	[/^([A-Z][a-zA-Z]*)/, 'NAME'],
	[/^(\d+)/, 'FORCE_LATIN'],
	[/^#{([^}]*)}/, 'FORCE_LATIN'],
	[/^([\.,;:!?()'"{}]+)/, 'PUNCTUATION'],
	[/^(\n+)/, 'NEWLINES'],
	[/^([^\S\r\n]+)/, 'WHITESPACE'], // whitespace, but not newline
	[/^([^\s]+)/, 'VERBATIM']
];

const tokenTypesWithManualGlyphExtension = manualGlyphExtensionTokenTypes.concat(tokenTypes);
console.log(tokenTypesWithManualGlyphExtension);

function getNextNonWhitespaceToken(tokens, startIndex = 0, count = 1) {
	for (let i = startIndex; i < tokens.length; i++) {
		if (tokens[i][0] !== 'WHITESPACE') {
			count--;
		}
		if (count <= 0 || tokens[i][0] === 'EOF') {
			return tokens[i];
		}
	}
	return ['EOF', 'EOF'];
}

function skipNonWhitespaceTokens(tokens, count) {
	while (count && tokens.length && tokens[0][0] !== 'EOF') {
		const deleted = tokens.shift();
		if (deleted[0] !== 'WHITESPACE') {
			count--;
		}
	}
}

function parsePi(tokens, piConfigs, number, isUCSUR = false) {
	const config = piConfigs[number] || {default: true};

	const includableWords = [];
	let defaultWords = 0;
	let defaultStillCounting = true;
	let wordsSoFar = 0;

	// Determine how many words (glyphs, actually. Stacked glyphs like toki+pona still count as one "word")
	// we could include, regardless of how many will actually
	// will include. And also determine the "default" number of included words.
	// We will need these for the LongPiModal.
	for (let i = 0; tokens[i][0] === 'WORD' || tokens[i][0] === 'WHITESPACE'; i++) {
		if (tokens[i][0] === 'WHITESPACE') {
			continue;
		}

		if (tokens[i][1] === 'pi') {
			// Can't swallow another long pi no matter what. We can swallow a regular pi though.
			const secondConfig = piConfigs[tokens[i][2]] || {default: true};
			if (!secondConfig.notLong) {
				break;
			}
		}

		// UCSUR long pi can never swallow a word that isn't in the UCSUR set.
		if (isUCSUR && !wordToUCSUR(tokens[i][1])) {
			break;
		}

		// Default ends when reaching a terminating particle. Default also ends on reaching a preposition,
		// if we currently have at least two words and the preposition has a viable prepositional object.
		if (defaultStillCounting) {
			if (terminatingParticles.has(tokens[i][1].toLowerCase())) {
				defaultStillCounting = false;
			} else if (preps.has(tokens[i][1].toLowerCase()) && wordsSoFar >= 2) {
				const next = getNextNonWhitespaceToken(tokens, i + 1);
				if (next[0] === 'WORD' && !terminatingParticles.has(next[1].toLowerCase())) {
					defaultStillCounting = false;
				}
			}
			if (defaultStillCounting) {
				defaultWords++;
			}
		}

		includableWords.push(tokens[i][1]);

		// Stacked glyphs count as two words for the purposes of determining if a preposition
		// will end the default.
		wordsSoFar += (tokens[i][1].indexOf('+') > -1 || tokens[i][1].indexOf('-') > -1) ? 2 : 1;	
	}

	// By default don't swallow 'a' at the end (mi jan pi toki pona a!)
	// But do include them in the middle (mi jan pi toki a pona!)
	while (defaultWords > 1 && includableWords[defaultWords - 1] === 'a') {
		defaultWords--;
	}

	// Now consider how many words we are actually meant to include, and consume those tokens.
	const wordsToInclude =
		config.notLong ? 0 :
		config.default ? defaultWords :
		Math.min(config.words, includableWords.length);

	if (isUCSUR) {
		if (wordsToInclude === 0) {
			return {type: 'pi', body: String.fromCodePoint(ucsur.pi), number, defaultWords, includableWords, config};
		} else {
			skipNonWhitespaceTokens(tokens, wordsToInclude);
			return {
				type: 'pi',
				body: String.fromCodePoint(ucsur.pi) + startLongGlyph + includableWords.slice(0, wordsToInclude).map(wordToUCSUR).join('') + endLongGlyph,
				number,
				includableWords,
				defaultWords,
				config
			};
		}
	}

	if (wordsToInclude === 0) {
		return {type: 'pi', body: 'pi', number, defaultWords, includableWords, config};
	} else {
		skipNonWhitespaceTokens(tokens, wordsToInclude);
		return {
			type: 'pi',
			body: 'pi+' + extendifyLinjaSike(includableWords.slice(0, wordsToInclude)),
			number,
			includableWords,
			defaultWords,
			config
		};
	}
}

function cartouchifyLinjaSike(glyphs) {
	return `[${glyphs.map(x => '_' + x).join('')}]`;
}

function extendifyLinjaSike(glyphs) {
	return glyphs.map(x => '__' + x).join('');
}

function cartouchifyUCSUR(glyphs) {
	const ucsurGlyphs = glyphs.map(g => {
		const converted = wordToUCSURBasic(g);
		if (converted) {
			return converted;
		} else if (/^[\.:]+$/.test(g)) {
			// sitelen mora, for those fonts which support it
			return g.replace(/\./g, spMidDot).replace(/:/g, spColon)
		} else {
			return g;
		}
	});

	return startCartouche + ucsurGlyphs.join('') + endCartouche;
}

function wordToUCSUR(word, checkCombinations = true) {
	const plus = word.indexOf('+');
	if (plus > -1) {
		const first = wordToUCSURBasic(word.slice(0, plus));
		const second = wordToUCSURBasic(word.slice(plus + 1));
		return first && second ? first + zeroWidthJoiner + second : false;
	}

	const backtick = word.indexOf('`');
	if (backtick > -1) {
		const first = wordToUCSURBasic(word.slice(0, backtick));
		const second = wordToUCSURBasic(word.slice(backtick + 1));
		return first && second ? first + scalingJoiner + second : false;
	}

	const hyphen = word.indexOf('-');
	if (hyphen > -1) {
		const first = wordToUCSURBasic(word.slice(0, hyphen));
		const second = wordToUCSURBasic(word.slice(hyphen + 1));
		return first && second ? first + stackingJoiner + second : false;
	}

	return wordToUCSURBasic(word)
}

function wordToUCSURBasic(word) {
	return ucsur[word] ? String.fromCodePoint(ucsur[word]) : false;
}

export default {
	data() {
		return {
			text: '',
			useLongPi: window.localStorage.useLongPi !== 'false',
			useFancyXAlaX: window.localStorage.useFancyXAlaX !== 'false',
			useManualGlyphExtensions: window.localStorage.useManualGlyphExtensions !== 'false',
			font: window.localStorage.font || 'linja-sike',

			helpModalActive: false,

			cartoucheModalActive: false,
			cartoucheModalBaseWord: '',
			cartoucheModalGlyphs: [],
			cartoucheChanges: 0,

			piConfigs: [],
			longPiModalActive: false,
			longPiModalPiece: null
		}
	},
	components: { PieceRenderer, HelpModal, CartoucheModal, LongPiModal },
	mounted() {
		M.AutoInit();
	},
	computed: {
		tokensAndPiCount() {
			const lexer = new TinyLex(
				this.text,
				this.useManualGlyphExtensions && this.fontSupportsGlyphExtensions ? tokenTypesWithManualGlyphExtension : tokenTypes
			);
			const tokens = [];
			let piCount = 0;

			for (const token of lexer) {
				if (token[0] === 'WORD' && token[1] === 'pi') {
					token.push(piCount++);
				}
				tokens.push(token);
			}

			return {tokens, piCount};
		},

		renderedLinjaSike() {
			const tokens = this.tokensAndPiCount.tokens.slice();
			const result = [];
			let currentNormal = '';

			const addNormal = text => currentNormal += text;
			const addSpecial = piece => {
				if (currentNormal) {
					result.push({type: 'normal', body: currentNormal});
				}
				currentNormal = '';
				result.push(piece);
			};

			while (tokens.length && tokens[0][0] !== 'EOF') {
				let [type, text, number] = tokens.shift();

				switch (type) {
					case 'WHITESPACE':
						addNormal(' ');
						if (text.length > 1) {
							for (let i = 0; i < text.length - 1; i++) {
								addNormal('zz ');
							}
						}
						break;
					case 'NAME':
						const baseWord = text.toUpperCase();
						addSpecial({type: 'name', baseWord, body: cartouchifyLinjaSike(this.getSavedCartouche(baseWord))});
						break;
					case 'FORCE_LATIN':
						addNormal(text.toUpperCase().split(/\s+/g).join(' zz '));
						break;
					case 'MANUAL_CARTOUCHE':
						addNormal(text ? cartouchifyLinjaSike(text.split(/\s+/g)) : '[]');
						break;
					case 'MANUAL_GLYPH_EXTENSION_L': {
						const [extension, extendedWord] = text.replace(/`/g, '+').split('}');
						const words = extension.split(/\s+/g);
						addNormal(`${extendifyLinjaSike(words)}<${extendedWord}`);
						break;
					}
					case 'MANUAL_GLYPH_EXTENSION_R': {
						const [extendedWord, extension] = text.replace(/`/g, '+').split('{');
						const words = extension.split(/\s+/g);
						addNormal(`${extendedWord}>${extendifyLinjaSike(words)}`);
						break;
					}
					case 'MANUAL_GLYPH_EXTENSION_LR': {
						const [extensionL, rest] = text.replace(/`/g, '+').split('}');
						const [extendedWord, extensionR] = rest.split('{');
						const wordsL = extensionL.split(/\s+/g);
						const wordsR = extensionR.split(/\s+/g);
						addNormal(`${extendifyLinjaSike(wordsL)}<${extendedWord}>${extendifyLinjaSike(wordsR)}`);
						break;
					}
					case 'NEWLINES':
						addSpecial({type: 'newlines', html: Array.from(text).map(() => '<br>').join('')});
						break;
					case 'WORD':
						if (this.useLongPi && text === 'pi') {
							addSpecial(parsePi(tokens, this.piConfigs, number));
							break;
						}

						text = text.replace(/`/g, '+');

						if (this.useFancyXAlaX && this.fontSupportsFancyXAlaX && !terminatingParticles.has(text)) {
							const next = getNextNonWhitespaceToken(tokens);
							if (next[0] === 'WORD' && next[1] === 'ala') {
								const nextNext = getNextNonWhitespaceToken(tokens, 0, 2);
								if (nextNext[0] === 'WORD' && nextNext[1] === text) {
									skipNonWhitespaceTokens(tokens, 2);
									addNormal(`__${text}<ala>__${text}`);
									break;
								}
							}
						}	
						addNormal(text);
						break;
					default:
						addNormal(text);
				}
			}

			if (currentNormal) {
				result.push({type: 'normal', body: currentNormal});
			}

			return result;
		},

		renderedUCSUR() {
			const tokens = this.tokensAndPiCount.tokens.slice();
			const result = [];
			let currentNormal = '';
			let lastLatin;

			const addNormal = text => currentNormal += text;
			const addSpecial = piece => {
				if (currentNormal) {
					result.push({type: 'normal', body: currentNormal});
				}
				currentNormal = '';
				result.push(piece);
			};

			while (tokens.length && tokens[0][0] !== 'EOF') {
				const [type, text, number] = tokens.shift();
				const wasLastLatin = lastLatin;
				lastLatin = false;
				switch (type) {
					case 'WHITESPACE':
						// If they typed a bunch of spaces then we will output a bunch of spaces
						if (text.length > 1) {
							addNormal(text.substring(1));
						} else {
							// Zero width space between SP glyphs is necessary to allow line breaking
							// Between latin words we want a proper space
							addNormal(wasLastLatin ? ' ' : zeroWidthSpace);
						}
						break;
					case 'NAME':
						const baseWord = text.toUpperCase();
						// Zero width space necessary to allow line-wrapping
						addSpecial({type: 'name', baseWord, body: cartouchifyUCSUR(this.getSavedCartouche(baseWord))});
						break;
					case 'MANUAL_CARTOUCHE':
						addNormal(text ? cartouchifyUCSUR(text.split(/\s+|\b/g)) : startCartouche + endCartouche);
						break;
					case 'MANUAL_GLYPH_EXTENSION_L': {
						const [extension, extendedWord] = text.split('}');
						// convert words to UCSUR, delete spaces, but preserve 2+ spaces in a row so we can {      }kijetesantakalu B) 
						const words = extension.replace(/[\w\-+`]+/g, x => wordToUCSUR(x) || x).replace(/\s+/g, x => x.length >= 2 ? x.substring(1) : '');
						addNormal(startReverseLongGlyph + words + endReverseLongGlyph + (wordToUCSUR(extendedWord) || extendedWord));
						break;
					}
					case 'MANUAL_GLYPH_EXTENSION_R': {
						const [extendedWord, extension] = text.replace(/`/g, '+').split('{');
						const words = extension.replace(/[\w\-+`]+/g, x => wordToUCSUR(x) || x).replace(/\s+/g, x => x.length >= 2 ? x.substring(1) : '');
						addNormal((wordToUCSUR(extendedWord) || extendedWord) + startLongGlyph + words + endLongGlyph);
						break;
					}
					case 'MANUAL_GLYPH_EXTENSION_LR': {
						const [extensionL, rest] = text.replace(/`/g, '+').split('}');
						const [extendedWord, extensionR] = rest.split('{');
						const wordsL = extensionL.replace(/[\w\-+`]+/g, x => wordToUCSUR(x) || x).replace(/\s+/g, x => x.length >= 2 ? x.substring(1) : '');
						const wordsR = extensionR.replace(/[\w\-+`]+/g, x => wordToUCSUR(x) || x).replace(/\s+/g, x => x.length >= 2 ? x.substring(1) : '');
						addNormal(
							startReverseLongGlyph + wordsL + endReverseLongGlyph +
							(wordToUCSUR(extendedWord) || extendedWord) +
							startLongGlyph + wordsR + endLongGlyph
						);
						break;
					}
					case 'WORD':
						if (this.useLongPi && text === 'pi') {
							addSpecial(parsePi(tokens, this.piConfigs, number, true));
							break;
						}

						const converted = wordToUCSUR(text);

						if (this.useFancyXAlaX && this.fontSupportsFancyXAlaX && !terminatingParticles.has(text) && converted) {
							const next = getNextNonWhitespaceToken(tokens);
							if (next[0] === 'WORD' && next[1] === 'ala') {
								const nextNext = getNextNonWhitespaceToken(tokens, 0, 2);
								if (nextNext[0] === 'WORD' && nextNext[1] === text) {
									skipNonWhitespaceTokens(tokens, 2);
									addNormal(startReverseLongGlyph + converted + endReverseLongGlyph + String.fromCodePoint(ucsur.ala) + startLongGlyph + converted + endLongGlyph);
									break;
								}
							}
						}
						
						if (converted) {
							addNormal(converted);
						} else {
							addNormal(text);
							lastLatin = true;
						}
						break;
					case 'NEWLINES':
						addSpecial({type: 'newlines', html: Array.from(text).map(() => '<br>').join('')});
						break;
					default:
						addNormal(text);
						lastLatin = true;

				}
			}

			if (currentNormal) {
				result.push({type: 'normal', body: currentNormal});
			}

			return result;
		},

		numberOfPis() {
			return this.tokensAndPiCount.piCount;
		},

		fontSupportsFancyXAlaX() {
			return this.font === 'linja-sike' || this.font === 'sitelen-kiwen-seli-juniko';
		},

		fontSupportsGlyphExtensions() {
			return this.font === 'linja-sike' || this.font === 'sitelen-kiwen-seli-juniko';
		}
	},
	methods: {
		openCartoucheModal(baseWord) {
			this.cartoucheModalBaseWord = baseWord;
			this.cartoucheModalGlyphs = this.getSavedCartouche(baseWord);
			this.cartoucheModalActive = true;
		},
		cartoucheModalSubmitted(event) {
			this.cartoucheChanges++;
			window.localStorage[`cart-${event.baseWord}`] = event.glyphs.join(' ');
		},
		getSavedCartouche(baseWord) {
			this.cartoucheChanges;
			if (window.localStorage[`cart-${baseWord}`]) {
				return window.localStorage[`cart-${baseWord}`].split(' ');
			}
			if (presetCartouches[baseWord]) {
				return presetCartouches[baseWord];
			}
			return Array.from(baseWord);
		},
		openLongPiModal(piece) {
			this.longPiModalPiece = piece;
			this.longPiModalActive = true;
		},
		longPiModalSubmitted(config) {
			this.piConfigs[this.longPiModalPiece.number] = config;
		}
	},
	watch: {
		numberOfPis(n) {
			while (this.piConfigs.length < n) {
				this.piConfigs.push({default: true});
			}
			while (this.piConfigs.length > n) {
				this.piConfigs.pop();
			}
		},
		useLongPi(value) {
			window.localStorage.useLongPi = value;
		},
		useFancyXAlaX(value) {
			window.localStorage.useFancyXAlaX = value;
		},
		useManualGlyphExtensions(value) {
			window.localStorage.useManualGlyphExtensions = value;
		},
		font(value) {
			window.localStorage.font = value;
		}
	}
};
</script>

<style lang="scss">
@font-face {
	font-family: linjasike;
	src: url(/linja-sike-5.otf);
}

@font-face {
	font-family: nasinnanpa;
	src: url(/nasin-nanpa-2.5.1-lasina-kin.otf);
}

@font-face {
	font-family: sitelenselikiwenjuniko;
	src: url(/sitelenselikiwenjuniko.ttf);
}

header {
	padding-top: 10px;
	display: flex;
	justify-content: space-between;
	font-weight: bold;
}

.input-box {
	padding: 5px 10px 0 10px;
	margin: 2rem 0;
}

.options {
	padding: 10px;
	margin: 2rem 0;
	display: flex;
	flex-wrap: wrap;
	justify-content: space-evenly;
	align-items: center;

	> .input-field {
		min-width: 15em;
	}

	> * {
		margin: 0px 10px;
		> span {
			color: black;

			> .sitelen-pona {
				font-size: 22px !important;
			}
		}
	}
}

.sitelen-pona {
	font-family: linjasike;
}

.sitelen-pona-suli {
	font-family: linjasike;
	font-size: 50px;
	line-height: 1.2;
}

.sitelen-pona-ucsur {
	font-family: nasinnanpa;
}

.sitelen-pona-ucsur-suli {
	font-family: nasinnanpa;
	font-size: 50px;
	line-height: 1.3;
}

.sitelen-pona-ssk {
	font-family: sitelenselikiwenjuniko;
}

.sitelen-pona-ssk-suli {
	font-family: sitelenselikiwenjuniko;
	font-size: 50px;
	line-height: 1.3;
}

@media (max-width:600px) {
	.sitelen-pona-suli, .sitelen-pona-ucsur-suli, .sitelen-pona-ssk-suli {
		font-size: 30px;
	}
}

@media (min-width:600px) and (max-width:800px) {
	.sitelen-pona-suli, .sitelen-pona-ucsur-suli, .sitelen-pona-ssk-suli {
		font-size: 40px;
	}
}

.btn, .btn-large, .btn-small, .btn-flat {
	text-transform: unset !important;
}

.monospace {
	font-family: monospace;
}
</style>
