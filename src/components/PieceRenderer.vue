<template>
	<div class="piece-renderer red lighten-4 z-depth-2" :class="{'hidden': pieces.length === 0}">
		<template v-for="(piece, idx) in pieces">
			<span v-if="piece.addZZ"> zz </span>

			<span class="name" v-if="piece.type === 'name'" :key="idx" @click="$emit('name', piece.baseWord)">{{piece.body}}</span>
			<span class="pi" v-if="piece.type === 'pi'" :key="idx" @click="$emit('pi', piece)">{{piece.body}}</span>
			<span class="normal" v-if="piece.type === 'normal'" :key="idx">{{piece.body}}</span>
			<span class="newlines" v-if="piece.type === 'newlines'" v-html="piece.html" />
		</template>
	</div>
</template>

<script>
export default {
	name: 'PieceRenderer',
	props: ['pieces']
};
</script>

<style lang="scss">
.piece-renderer {
	padding: 10px;
	margin: 2rem 0;

	> .name, > .pi {
		color: #303f9f;
		cursor: pointer;

		&:hover {
			background-color: #e57373;
		}
	}

	&.sitelen-emoji-suli > .name:not(:hover) {
		background-color: #ef9a9a;
	}

	> .normal {
		white-space: pre-wrap;
	}

	&.monospace {
		.name, .pi {
			font-weight: bold;
		}
	}

	&.hidden {
		display: none;
	}
}
</style>