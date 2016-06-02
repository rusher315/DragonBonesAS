package dragonBones.starling
{
	import dragonBones.core.BaseObject;
	import dragonBones.textures.TextureAtlasData;
	import dragonBones.textures.TextureData;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public final class StarlingTextureAtlasData extends TextureAtlasData
	{
		public static function fromTextureAtlas(textureAtlas:TextureAtlas):StarlingTextureAtlasData
		{
			const textureAtlasData:StarlingTextureAtlasData = BaseObject.borrowObject(StarlingTextureAtlasData) as StarlingTextureAtlasData;
			for each(var textureName:String in textureAtlas.getNames())
			{
				const textureData:StarlingTextureData = textureAtlasData.generateTexture() as StarlingTextureData;
				textureData.name = textureName;
				textureData.texture = textureAtlas.getTexture(textureName);
				//textureData.rotate;
				//textureData.region;
				//textureData.frame;
				textureAtlasData.addTexture(textureData);
			}
			
			//textureAtlasData.texture = textureAtlas.texture;
			//textureAtlasData.scale = textureAtlas.texture.scale;
			return textureAtlasData;
		}
		
		public var texture:Texture = null;
		
		public function StarlingTextureAtlasData()
		{
			super(this);
		}
		
		override protected function _onClear():void
		{
			super._onClear();
			
			if (texture)
			{
				//texture.dispose();
				texture = null;
			}
		}
		
		override public function generateTexture():TextureData
		{
			return BaseObject.borrowObject(StarlingTextureData) as StarlingTextureData;
		}
	}
}