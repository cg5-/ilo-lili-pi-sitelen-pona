<!-- https://onlineutf8tools.com/convert-utf8-to-html-entities -->

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
				sina pana e toki pona kepeken sitelen Lasina la, ilo li pana e toki pona ni kepeken nasin
				pi <em><a href="https://wyub.github.io/tokipona/linjasike">linja sike</a></em> anu nasin UCSUR.
			</p>
			<p v-else>
				This is a little <em>sitelen pona</em> tool.
				If you type Toki Pona Latin text, it will write that text in <em>sitelen pona</em> using the
				features of <em><a href="https://wyub.github.io/tokipona/linjasike">linja sike</a></em> or using UCSUR.
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

			<h5 v-if="useTP">o wan e sitelen tu</h5>
			<h5 v-else>Combined glyphs</h5>

			<!-- v-show instead of v-if as to not break the Materialize tooltips -->
			<p v-show="useTP">
				sina ken wan e nimi tu kepeken sitelen <code>+</code> anu <code>-</code> anu <code>`</code>.
				sina kepeken sitelen ante la, nimi li kama wan kepeken nasin ante. tenpo mute la, nasin pi sitelen
				<code>+</code> li pona nanpa wan.
				<a href="#" data-tooltip="+ → zero width joiner; - → stacking joiner; ` → scaling joiner">?</a>
			</p>
			<p v-show="!useTP">
				You can combine two glyphs using <code>+</code>, <code>-</code> or <code>`</code>. The different characters
				will combine the glyphs in different ways. Usually, <code>+</code> is the best.
				<a href="#" data-tooltip="+ → zero width joiner; - → stacking joiner; ` → scaling joiner">?</a>
			</p>

			<div class="example">
				<div class="before">
					<div>[linja sike] soweli pona soweli+pona soweli-pona</div>
					<div>[nasin nanpa] ijo-pona ijo`pona</div>
				</div>
				<div class="arrow"><div>→</div></div>
				<div class="after">
					<div class="sitelen-pona">soweli pona zz soweli+pona zz soweli-pona</div>
					<div class="sitelen-pona-ucsur">&#xF190C;&#xF1995;&#xF1954; &#xF190C;&#xF1996;&#xF1954;</div>
				</div>
			</div>

			<h5 v-if="useTP">o suli e sitelen mute</h5>
			<h5 v-else>Other long glyphs</h5>

			<p v-if="useTP">
				poki <code>{ }</code> li luka e poka pi nimi ante la, sitelen li kama suli lon poka ni.
				nimi lon insa pi poki <code>{ }</code> li kama insa pi sitelen suli. poka tu li ken.
				taso, sitelen ale ala li ken kama suli. linja ante la, nimi ante li ken ni.
			</p>
			<p v-else>
				If you put some words in <code>{ }</code> and connect that to the side of another word, that word will
				extend to contain the words inside the <code>{ }</code>. You can do this on both sides.
				But not every word can be extended in this way. Which words can be extended depends on the font.
			</p>

			<div class="example">
				<div class="before">
					<div>[linja sike] <code>o awen{pona} kepeken{ilo ni}</code></div>
					<div>[sitelen seli kiwen] <code>mi {wile}kama</code></div>
				</div>
				<div class="arrow"><div>→</div></div>
				<div class="after">
					<div class="sitelen-pona">o awen>__pona kepeken>__ilo__ni</div>
					<div class="sitelen-pona-ssk">&#xf1934;&ZeroWidthSpace;&#xf199a;&#xf1977;&#xf199b;&#xf1916;</div>
				</div>
			</div>

			<h5 v-if="useTP">ijo ante</h5>
			<h5 v-else>Miscellaneous</h5>

			<p v-if="useTP">
				kulupu nimi li lon insa poki <code>#{ }</code> la, ona li awen sitelen Lasina. 
			</p>
			<p v-else>
				If you surround some text with <code>#{ }</code>, it will stay as Latin text.
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

			<p v-if="useTP">
				<em>nasin nanpa</em> en <em>sitelen seli kiwen</em> la, <em>sitelen mora</em> li ken.
			</p>
			<p v-else>
				With <em>nasin nanpa</em> and <em>sitelen seli kiwen</em>, you can use <em>sitelen mora</em>.
			</p>

			<div class="example">
				<div class="before"><div>mi jan [ma.ko:]</div></div>
				<div class="arrow"><div>→</div></div>
				<div class="after sitelen-pona-ssk"><div>&#xf1934;&ZeroWidthSpace;&#xf1911;&ZeroWidthSpace;&#xf1990;&#xf1930;&#xf199c;&#xf191c;&#xf199d;&#xf1991;</div></div>
			</div>

			<h4 v-if="useTP">jan pali linja</h4>
			<h4 v-else>Font credits</h4>

			<ul v-if="useTP">
				<li>jan Lipamanka/kulupu poki li pali e <a href="https://wyub.github.io/tokipona/linjasike"><em>linja sike</em></a>.</li>
				<li>jan Itan li pali e <a href="https://github.com/ETBCOR/nasin-nanpa"><em>nasin nanpa</em></a>.</li>
				<li>jan Lepaka li pali e <a href="http://www.kreativekorp.com/software/fonts/sitelenselikiwen"><em>sitelen seli kiwen</em></a>.</li>
				<li>kulupu pi sitelen Emoji li pali e <a href="https://sites.google.com/view/sitelenemoji"><em>sitelen Emoji</em></a>.</li>
			</ul>
			<p v-if="useTP">sina ale li pona a!</p>

			<ul v-if="!useTP">
				<li><em>jan Lipamanka/kulupu poki</em> made <a href="https://wyub.github.io/tokipona/linjasike"><em>linja sike</em></a>.</li>
				<li><em>jan Itan</em> made <a href="https://github.com/ETBCOR/nasin-nanpa"><em>nasin nanpa</em></a>.</li>
				<li><em>jan Lepaka</em> made <a href="http://www.kreativekorp.com/software/fonts/sitelenselikiwen"><em>sitelen seli kiwen</em></a>.</li>
				<li>The <em>sitelen Emoji</em> community made <a href="https://sites.google.com/view/sitelenemoji"><em>sitelen Emoji</em></a>.</li>
			</ul>
			<p v-if="!useTP">Thanks everyone!</p>

			<h4 v-if="useTP">toki ilo</h4>
			<h4 v-else>Source code</h4>

			<p v-if="useTP">
				jan Mako li pali e ilo ni.
				<a href="https://github.com/cg5-/ilo-lili-pi-sitelen-pona">sina ken lukin e toki ilo pi ilo ni lon lipu GitHub.</a>
				sina ken pana e wile ante tawa mi lon lipu ni.
			</p>
			<p v-else>
				<em>jan Mako</em> made this. <br>
				<a href="https://github.com/cg5-/ilo-lili-pi-sitelen-pona">The source code is on GitHub.</a> Pull requests are welcome.
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

		M.Tooltip.init(this.$el.querySelectorAll("[data-tooltip]"))
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

		> div.after {
			font-size: 22px;
			line-height: 1.1;
		}
	}
}
</style>