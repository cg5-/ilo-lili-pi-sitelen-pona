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
			<label>
				<input type="checkbox" v-model="useLongPi" />
				<span>o kepeken nimi "pi" suli <span class="sitelen-pona">(jan pi+__pana__sona)</span></span>
			</label>
			<label>
				<input type="checkbox" v-model="useFancyXAlaX" />
				<span>o kepeken nasin "X ala X" suwi <span class="sitelen-pona">(__pali&lt;ala&gt;__pali)</span></span>
			</label>
		</div>

		<PieceRenderer
			class="monospace"
			:pieces="rendered"
			@name="openCartoucheModal($event)"
			@pi="openLongPiModal($event)"
		/>

		<PieceRenderer
			class="sitelen-pona-suli"
			:pieces="rendered"
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

const terminatingParticles = new Set(["anu", "e", "en", "la", "li", "o", "pi"]);
const preps = new Set(["tawa", "tan", "lon", "kepeken", "sama"]);

const tokenTypes = [
	[/^@{([^}]*)}/, 'VERBATIM'],
	[/^\[([^_\n]*)\]/, 'MANUAL_CARTOUCHE'],
	[/^([a-z][\w\-+]*)/, 'WORD'],
	[/^([A-Z][a-zA-Z]*)/, 'NAME'],
	[/^(\d+)/, 'FORCE_LATIN'],
	[/^#{([^}]*)}/, 'FORCE_LATIN'],
	[/^(['"]+)/, 'HARMLESS_PUNCTUATION'],
	[/^[\.,;:!()]+/, 'TERMINATING_PUNCTUATION'],
	[/^(\n+)/, 'NEWLINES'],
	[/^([^\S\r\n]+)/], // Ignore whitespace, except for newlines
	[/^([^\s]+)/, 'VERBATIM']
];

function parsePi(tokens, piConfigs, number) {
	const config = piConfigs[number] || {default: true};

	const includableWords = [];
	let defaultWords = 0;
	let defaultStillCounting = true;
	let wordsSoFar = 0;

	// Determine how many words (glyphs, actually. Stacked glyphs like toki+pona still count as one "word")
	// we could include, regardless of how many will actually
	// will include. And also determine the "default" number of included words.
	// We will need these for the LongPiModal.
	for (let i = 0; tokens[i][0] === 'WORD'; i++) {
		if (tokens[i][1] === 'pi') {
			// Can't swallow another long pi no matter what. We can swallow a regular pi though.
			const secondConfig = piConfigs[tokens[i][2]] || {default: true};
			if (!secondConfig.notLong) {
				break;
			}
		}

		// Default ends when reaching a terminating particle. Default also ends on reaching a preposition,
		// if we currently have at least two words and the preposition has a viable prepositional object.
		if (defaultStillCounting) {
			if (
				terminatingParticles.has(tokens[i][1].toLowerCase()) ||
				preps.has(tokens[i][1].toLowerCase()) && wordsSoFar >= 2 && tokens[i + 1][0] === 'WORD' && !terminatingParticles.has(tokens[i + 1][1].toLowerCase())
			) {
				defaultStillCounting = false;
			} else {
				defaultWords++;
			}
		}

		includableWords.push(tokens[i][1]);

		// Stacked glyphs count as two words for the purposes of determining if a preposition
		// will end the default.
		wordsSoFar += (tokens[i][1].indexOf('+') > -1 || tokens[i][1].indexOf('-') > -1) ? 2 : 1;
		
	}

	// Now consider how many words we are actually meant to include, and consume those tokens.
	const wordsToInclude =
		config.notLong ? 0 :
		config.default ? defaultWords :
		Math.min(config.words, includableWords.length);

	if (wordsToInclude === 0) {
		return {type: 'pi', body: ' pi', number, defaultWords, includableWords, config};
	} else {
		tokens.splice(0, wordsToInclude);
		return {
			type: 'pi',
			body: ' pi+' + includableWords.slice(0, wordsToInclude).map(x => '__' + x).join(''),
			number,
			includableWords,
			defaultWords,
			config
		};
	}
}

function cartouchify(glyphs) {
	return ` [${glyphs.map(x => '_' + x).join('')}]`;
}

export default {
	data() {
		return {
			text: '',
			useLongPi: window.localStorage.useLongPi !== 'false',
			useFancyXAlaX: window.localStorage.useFancyXAlaX !== 'false',

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
			const lexer = new TinyLex(this.text, tokenTypes);
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

		rendered() {
			const tokens = this.tokensAndPiCount.tokens.slice();

			const result = [];
			let lastType = null;
			let lastText = null;
			
			while (tokens.length && tokens[0][0] !== 'EOF') {
				const [type, text, number] = tokens.shift();
				switch (type) {
					case 'NAME':
						const baseWord = text.toUpperCase();
						result.push({type: 'name', baseWord, body: cartouchify(this.getSavedCartouche(baseWord))});
						break;
					case 'FORCE_LATIN':
						result.push({
							type: 'normal',
							body: ' ' + text.toUpperCase().split(/\s+/g).join(' zz '),
							addZZ: lastType === 'FORCE_LATIN'
						});
						break;
					case 'MANUAL_CARTOUCHE':
						result.push({type: 'normal', body: text ? cartouchify(text.split(/\s+/g)) : ' []'});
						break;
					case 'NEWLINES':
						result.push({type: 'newlines', html: Array.from(text).map(() => '<br>').join('')});
						break;
					default:
						if (this.useLongPi && type === 'WORD' && text === 'pi') {
							result.push(parsePi(tokens, this.piConfigs, number));
						} else if (
							this.useFancyXAlaX && type === 'WORD' && tokens.length >= 2
							&& tokens[0][0] === 'WORD' && tokens[0][1] === 'ala'
							&& tokens[1][0] === 'WORD' && tokens[1][1] === text && !terminatingParticles.has(tokens[1][1])
						) {
							tokens.shift();
							tokens.shift();
							result.push({type: 'normal', body: ` __${text}<ala>__${text}`});
						} else {
							result.push({type: 'normal', body: ' ' + text});
						}
				}
				lastType = type;
				lastText = text;
			}

			return result;
		},

		numberOfPis() {
			return this.tokensAndPiCount.piCount;
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
		}
	}
};
</script>

<style lang="scss">
@font-face {
	font-family: linjasike;
	src: url(https://wyub.github.io/tokipona/linja-sike-5.otf);
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

	> label {
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
	line-height: 1.1;
}

@media (max-width:600px) {
	.sitelen-pona-suli {
		font-size: 30px;
	}
}

@media (min-width:600px) and (max-width:800px) {
	.sitelen-pona-suli {
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
