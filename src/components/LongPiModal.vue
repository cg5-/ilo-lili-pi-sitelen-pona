<template>
	<div class="modal long-pi-modal">
		<div class="modal-content" v-if="piece">
			<label>
				<input type="checkbox" v-model="this.useLongPi">
				<span>nimi "pi" suli</span>
			</label>
			<template v-if="useLongPi">
				<div class="sitelen-pona-suli">{{preview}}</div>
				<button href="#!" class="waves-effect waves-light btn" :disabled="length <= 1" @click="length--">&lt; o kama lili</button>
				<button href="#!" class="waves-effect waves-light btn" :disabled="length >= piece.includableWords.length" @click="length++">o kama suli &gt;</button>
			</template>
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
	props: ['active', 'piece'],
	data() {
		return {
			useLongPi: true,
			length: 0
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
				if (this.piece.config.notLong) {
					this.useLongPi = false;
					this.length = this.piece.defaultWords;
				} else {
					this.useLongPi = true;
					if (this.piece.config.default) {
						this.length = this.piece.defaultWords;
					} else {
						this.length = Math.min(this.piece.config.words, this.piece.includableWords.length);
					}
				}
				this.modalInstance.open();
			} else {
				this.modalInstance.close();
			}
		},
	},
	methods: {
		close() {
			this.$emit('update:active', false);
		},
		submit() {
			const config =
				!this.useLongPi ? {notLong: true} :
				this.length === this.piece.defaultWords ? {default: true} :
				{words: this.length};

			this.$emit('submit', config);
			this.close();
		}
	},
	computed: {
		preview() {
			if (this.piece.includableWords.length === 0) return 'pi';
			const included = 'pi+' + this.piece.includableWords.slice(0, this.length).map(x => '__' + x).join('');
			const excluded = this.piece.includableWords.slice(this.length).join(' ');
			return `${included} ${excluded}`;
		}
	}
};
</script>

<style lang="scss">
.long-pi-modal {
	> .modal-content {
		> .sitelen-pona-suli {
			margin: 10px 0;
		}

		> button {
			margin-right: 5px;
		}
	}
}
</style>