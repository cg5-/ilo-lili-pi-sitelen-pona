<template>
	<div class="modal modal-fixed-footer help-modal">
		<div class="modal-content">
			<div class="switch">
				<label>
					English
					<input type="checkbox" v-model="useTP" />
					<span class="lever" />
					toki pona
				</label>
			</div>
			
			<h3 v-if="useTP">ni li seme?</h3>
			<h3 v-else>What's this?</h3>
			<p v-if="useTP">
				ni li ilo lili pi sitelen pona.
				sina pana e toki pona kepeken sitelen Lasina la, ilo li pana e toki pona ni kepeken nasin pi <a href="https://wyub.github.io/tokipona/linjasike">linja sike</a>.
				(taso, sina kepeken linja ante la, nimi ni li ken pakala.)
			</p>
			<p v-else>
				This is a little <em>sitelen pona</em> tool.
				If you type Toki Pona Latin text, it will write that text using the features of <em><a href="https://wyub.github.io/tokipona/linjasike">linja sike</a></em>.
				(However, if you use a different font, its output might not work correctly.)
			</p>

			<h4 v-if="useTP">ken pi ilo ni</h4>
			<h4 v-else>Features</h4>

			<h5 v-if="useTP">poki sitelen</h5>
			<h5 v-else>Cartouches</h5>

			<p v-if="useTP">
				nimi li jo e sitelen nanpa wan suli la, ilo li ante e ni tawa poki sitelen. sina luka e poki la, sina ken ante e kulupu sitelen lon insa poki.
				ni la, ilo li awen sona e sitelen pi wile sina. sina pana e nimi sama lon tenpo kama la, ilo li pana e kulupu sitelen sama.
			</p>
			<p v-else>
				If a word starts with a capital letter, it will be converted to a cartouche. If you click the cartouche, you can choose which glyphs are used.
				In that case, it will remember the glyphs you chose. If you write the same name in the future, it will use the same glyphs.
			</p>

			<div class="example">
				<div class="before"><div>ma Kanata li suli</div></div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona"><div>ma [_kasi_alasa_nasin_awen_telo_a] li suli</div></div>
			</div>

			<h5 v-if="useTP">nimi "pi" suli</h5>
			<h5 v-else>Long <em>pi</em></h5>

			<p v-if="useTP">
				sina wile la, ilo li ken ante e kulupu nimi pi nimi "pi" tawa nimi "pi" suli.
			</p>
			<p v-else>
				If you want, it can convert <em>pi</em> phrases into a "long <em>pi</em>".
			</p>

			<div class="example">
				<div class="before"><div>jan pi pana sona li suli</div></div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona"><div>jan pi+__pana__sona li suli</div></div>
			</div>

			<p v-if="useTP">
				lon tenpo lili la, ilo li ken ala sona e ni: nimi seme o lon insa pi nimi "pi" suli? ni la, sina luka e nimi "pi" suli la, sina ken ante e ni.
			</p>
			<p v-else>
				Occasionally, it can't tell which words are supposed to be inside the long <em>pi</em>. In that case, if you click the long <em>pi</em>, you can change this.
			</p>

			<div class="example">
				<div class="before"><div>mi sona e suli pi poki kiwen tawa mi</div></div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona">
					<div>ike: zz mi sona e suli pi+__poki__kiwen tawa mi</div>
					<div>pona: zz mi sona e suli pi+__poki__kiwen__tawa__mi</div>
				</div>
			</div>

			<h5 v-if="useTP">nasin "X ala X" suwi</h5>
			<h5 v-else>Fancy <em>X ala X</em></h5>

			<p v-if="useTP">
				sina wile la, ilo li ken sitelen e kulupu nimi "X ala X" kepeken nasin suwi.
			</p>
			<p v-else>
				If you want, it can write "X ala X" phrases in a fancy way.
			</p>

			<div class="example">
				<div class="before"><div>sina pali ala pali e lipu+ni</div></div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona"><div>sina __pali&lt;ala&gt;__pali e lipu+ni</div></div>
			</div>

			<h5 v-if="useTP">ijo ante</h5>
			<h5 v-else>Miscellaneous</h5>

			<p v-if="useTP">
				kulupu nimi li lon insa poki <code>#{</code> <code>}</code> la, ona li awen sitelen Lasina. 
			</p>
			<p v-else>
				If you surround some text with <code>#{</code> <code>}</code>, it will stay as Latin text.
			</p>

			<div class="example">
				<div class="before">
					<div>ni li sitelen pona</div>
					<div>#{ni li sitelen Lasina}</div>
				</div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona">
					<div>ni li sitelen pona</div>
					<div>NI zz LI zz SITELEN zz LASINA</div>
				</div>
			</div>

			<p v-if="useTP">
				kulupu nimi li lon insa poki <code>@{</code> <code>}</code> la, ilo li ante ala e ona. 
			</p>
			<p v-else>
				If you surround some text with <code>@{</code> <code>}</code>, it won't be changed at all.
			</p>

			<div class="example">
				<div class="before">
					<div>Pingo</div>
					<div>@{Pingo}</div>
				</div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona">
					<div>[_P_I_N_G_O]</div>
					<div>Pingo</div>
				</div>
			</div>

			<p v-if="useTP">
				kulupu nimi li lon insa poki <code>[</code> <code>]</code> la, ona li kama poki sitelen. 
			</p>
			<p v-else>
				If you surround some text with <code>[</code> <code>]</code>, it will become a cartouche.
			</p>

			<div class="example">
				<div class="before"><div>mi jan [mije awen kepeken ona]</div></div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona"><div>mi jan [_mije_awen_kepeken_ona]</div></div>
			</div>

			<h4 v-if="useTP">jan pali</h4>
			<h4 v-else>Creators</h4>

			<p v-if="useTP">
				jan Mako li pali e ilo ni. <br>
				ken la, sina kin li ken pali e ilo ni. sina ken lukin e toki ilo pi ilo ni lon lipu GitHub. sina ken pana e wile ante tawa mi lon lipu ni. <br>
				jan Lipamanka/kulupu poki li pali e linja sike. ilo ni li kepeken linja ni. sina pona, jan Lipamanka o!
			</p>
			<p v-else>
				<em>jan Mako</em> made this. <br>
				Maybe you made this, too? The source code is on GitHub. Pull requests are welcome. <br>
				<em>jan Lipamanka/kulupu poki</em> made the font <em>linja sike</em>, which this uses. Thanks!
				
			</p>

		</div>
		<div class="modal-footer">
			<button class="waves-effect waves-light btn" @click="close" v-if="useTP">o weka</button>
			<button class="waves-effect waves-light btn" @click="close" v-else>Close</button>
		</div>
	</div>
</template>

<!--
			<p v-if="useTP">
				
			</p>
			<p v-else>
				
			</p>
			-->

<script>
export default {
	name: 'HelpModal',
	props: ['active'],
	data() {
		return {
			useTP: true
		}
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
				this.modalInstance.open();
			} else {
				this.modalInstance.close();
			}
		}
	},
	methods: {
		close() {
			this.$emit('update:active', false);
		}
	}
};
</script>

<style lang="scss">
.help-modal {
	.switch {
		text-align: right;
	}

	.example {
		display: flex;

		> div {
			flex: 1 1 0;
			text-align: center;
			vertical-align: middle;
			display: flex;
			flex-direction: column;
			justify-content: center;
		}

		> div.arrow {
			flex-grow: 0;
			font-size: 22px;
		}

		> .after.sitelen-pona {
			font-size: 22px;
			line-height: 1.1;
		}
	}
}
</style>