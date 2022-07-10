<template>
	<div class="modal modal-fixed-footer cartouche-modal">
		<div class="modal-content">
			<div class="letters">
				<div
					v-for="(glyph, idx) of currentGlyphs"
					:key="idx"
					class="letter z-depth-1"
					:class="{'selected': idx === selectedLetterIndex}"
					@click="selectedLetterIndex = idx"
				>
					<div class="latin">{{baseWord[idx]}}</div>
					<div class="sitelen-pona-suli">{{glyph}}</div>
				</div>
			</div>

			<div class="glyphs">
				<div
					v-for="glyph of availableGlyphs"
					class="glyph"
					:class="{[glyph.type]: true, 'selected': currentGlyphs[selectedLetterIndex] === glyph.glyph}"
					@click="selectGlyph(glyph.glyph)"
				>
					<div class="sitelen-pona-suli">{{glyph.glyph}}</div>
					<div class="latin">{{glyph.glyph}}</div>
				</div>
			</div>
		</div>
		<div class="modal-footer">
			<button class="waves-effect waves-red btn-flat" @click="close">o weka e ante ni</button>
			<button class="waves-effect waves-light btn green" @click="submit">o awen e ante ni</button>
		</div>
	</div>
</template>

<script>
import words from '../words.json';

export default {
	name: 'CartoucheModal',
	props: ['active', 'baseWord', 'glyphs'],
	data() {
		return {
			currentGlyphs: [],
			selectedLetterIndex: 0
		};
	},
	mounted() {
		this.modalInstance = M.Modal.init(this.$el, {
			onCloseStart: () => {
				this.$emit('update:active', false);
			}
		});
	},
	watch: {
		active(value) {
			if (value) {
				this.selectedLetterIndex = 0;
				this.currentGlyphs = this.glyphs.slice();
				this.modalInstance.open();
			} else {
				this.modalInstance.close();
			}
		},
		glyphs(value) {
			this.selectedLetterIndex = 0;
			this.currentGlyphs = value.slice();
		} 
	},
	methods: {
		close() {
			this.$emit('update:active', false);
		},
		selectGlyph(glyph) {
			if (this.currentGlyphs[this.selectedLetterIndex] !== glyph) {
				this.currentGlyphs[this.selectedLetterIndex] = glyph;
				if (this.selectedLetterIndex < this.baseWord.length - 1) {
					this.selectedLetterIndex++;
				}
			}
		},
		submit() {
			this.$emit('submit', {baseWord: this.baseWord, glyphs: this.currentGlyphs});
			this.close();
		}
	},
	computed: {
		availableGlyphs() {
			if (!this.baseWord) return [];
			return words[this.baseWord[this.selectedLetterIndex].toLowerCase()];
		}
	}
};
</script>

<style lang="scss">
.cartouche-modal {
	.letters {
		display: flex;
		flex-wrap: wrap;
		justify-content: center;
		align-items: center;

		> .letter {
			display: flex;
			flex-direction: column;
			align-items: center;
			text-align: center;
			margin: 5px;
			padding: 5px 10px;
			cursor: pointer;

			&:hover {
				background-color: #eeeeee;
			}

			&.selected {
				background-color: #bbdefb;
				cursor: unset;
			}
		}
	}

	.glyphs {
		display: flex;
		flex-wrap: wrap;
		justify-content: center;
		align-items: center;

		> .glyph {
			display: flex;
			flex-direction: column;
			align-items: center;
			text-align: center;
			margin: 5px;
			padding: 5px 10px;
			cursor: pointer;

			&.ku-suli {
				color: #303f9f;
			}

			&:hover {
				background-color: #eeeeee;
			}

			&.selected {
				background-color: #bbdefb;
				cursor: unset;
			}
		}
	}
}
</style>