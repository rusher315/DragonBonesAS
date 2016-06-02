﻿package dragonBones.animation
{
	import dragonBones.Bone;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.geom.Transform;
	import dragonBones.objects.BoneFrameData;
	import dragonBones.objects.BoneTimelineData;
	import dragonBones.objects.TweenFrameData;
	
	use namespace dragonBones_internal;
	
	/**
	 * @private
	 */
	public final class BoneTimelineState extends TweenTimelineState
	{
		public var bone:Bone;
		
		private var _tweenTransform:int;
		private var _tweenRotate:int;
		private var _tweenScale:int;
		private var _boneTransform:Transform;
		private var _originTransform:Transform;
		private const _transform:Transform = new Transform();
		private const _currentTransform:Transform = new Transform();
		private const _durationTransform:Transform = new Transform();
		
		public function BoneTimelineState()
		{
			super(this);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function _onClear():void
		{
			super._onClear();
			
			bone = null;
			
			_tweenTransform = TWEEN_TYPE_NONE;
			_tweenRotate = TWEEN_TYPE_NONE;
			_tweenScale = TWEEN_TYPE_NONE;
			_boneTransform = null;
			_originTransform = null;
			_transform.identity();
			_currentTransform.identity();
			_durationTransform.identity();
		}
		
		override protected function _onFadeIn():void
		{
			_originTransform = (this._timeline as BoneTimelineData).originTransform;
			_boneTransform = bone._animationPose;
		}
		
		private static const PI_D:Number = Math.PI * 2;
		
		override protected function _onArriveAtFrame(isUpdate:Boolean):void
		{
			super._onArriveAtFrame(isUpdate);
			
			const currentFrame:BoneFrameData = this._currentFrame as BoneFrameData;
			
			_currentTransform.copy(currentFrame.transform);
			
			_tweenTransform = TWEEN_TYPE_ONCE;
			_tweenRotate = TWEEN_TYPE_ONCE;
			_tweenScale = TWEEN_TYPE_ONCE;
			
			if (this._keyFrameCount > 1 && (this._tweenEasing != TweenFrameData.NO_TWEEN || this._curve))
			{
				const nextFrame:BoneFrameData = this._currentFrame.next as BoneFrameData;
				const nextTransform:Transform = nextFrame.transform;
				
				// Transform
				_durationTransform.x = nextTransform.x - _currentTransform.x;
				_durationTransform.y = nextTransform.y - _currentTransform.y;
				if (_durationTransform.x != 0 || _durationTransform.y != 0)
				{
					_tweenTransform = TWEEN_TYPE_ALWAYS;
				}
				
				// Rotate
				if (currentFrame.tweenRotate == currentFrame.tweenRotate)
				{
					if (currentFrame.tweenRotate)
					{
						if (currentFrame.tweenRotate > 0 ? nextTransform.skewY >= _currentTransform.skewY : nextTransform.skewY <= _currentTransform.skewY) {
							const rotate:int = currentFrame.tweenRotate > 0? currentFrame.tweenRotate - 1: currentFrame.tweenRotate + 1;
							_durationTransform.skewX = nextTransform.skewX - _currentTransform.skewX + PI_D * rotate;
							_durationTransform.skewY = nextTransform.skewY - _currentTransform.skewY + PI_D * rotate;
						} 
						else
						{
							_durationTransform.skewX = nextTransform.skewX - _currentTransform.skewX + PI_D * currentFrame.tweenRotate;
							_durationTransform.skewY = nextTransform.skewY - _currentTransform.skewY + PI_D * currentFrame.tweenRotate;
						}
					}
					else
					{
						_durationTransform.skewX = Transform.normalizeRadian(nextTransform.skewX - _currentTransform.skewX);
						_durationTransform.skewY = Transform.normalizeRadian(nextTransform.skewY - _currentTransform.skewY);
					}
					
					if (_durationTransform.skewX != 0 || _durationTransform.skewY != 0)
					{
						_tweenRotate = TWEEN_TYPE_ALWAYS;
					}
				}
				else 
				{
					_durationTransform.skewX = 0;
					_durationTransform.skewY = 0;
				}
				
				// Scale
				if (currentFrame.tweenScale)
				{
					_durationTransform.scaleX = nextTransform.scaleX - _currentTransform.scaleX;
					_durationTransform.scaleY = nextTransform.scaleY - _currentTransform.scaleY;
					if (_durationTransform.scaleX != 0 || _durationTransform.scaleY != 0)
					{
						_tweenScale = TWEEN_TYPE_ALWAYS;
					}
				}
				else
				{
					_durationTransform.scaleX = 0;
					_durationTransform.scaleY = 0;
				}
			}
			else
			{
				_durationTransform.x = 0;
				_durationTransform.y = 0;
				_durationTransform.skewX = 0;
				_durationTransform.skewY = 0;
				_durationTransform.scaleX = 0;
				_durationTransform.scaleY = 0;
			}
		}
		
		override protected function _onUpdateFrame(isUpdate:Boolean):void
		{
			if (_tweenTransform || _tweenRotate || _tweenScale)
			{
				super._onUpdateFrame(isUpdate);
				
				if (_tweenTransform)
				{
					if (_tweenTransform == TWEEN_TYPE_ONCE)
					{
						_tweenTransform = TWEEN_TYPE_NONE;
					}
					
					if (this._animationState.additiveBlending) // Additive blending
					{
						_transform.x = _currentTransform.x + _durationTransform.x * this._tweenProgress;
						_transform.y = _currentTransform.y + _durationTransform.y * this._tweenProgress;
					}
					else // Normal blending
					{
						_transform.x = _originTransform.x + _currentTransform.x + _durationTransform.x * this._tweenProgress;
						_transform.y = _originTransform.y + _currentTransform.y + _durationTransform.y * this._tweenProgress;
					}
				}
				
				if (_tweenRotate)
				{
					if (_tweenRotate == TWEEN_TYPE_ONCE)
					{
						_tweenRotate = TWEEN_TYPE_NONE;
					}
					
					if (this._animationState.additiveBlending) // Additive blending
					{
						_transform.skewX = _currentTransform.skewX + _durationTransform.skewX * this._tweenProgress;
						_transform.skewY = _currentTransform.skewY + _durationTransform.skewY * this._tweenProgress;
					}
					else // Normal blending
					{
						_transform.skewX = _originTransform.skewX + _currentTransform.skewX + _durationTransform.skewX * this._tweenProgress;
						_transform.skewY = _originTransform.skewY + _currentTransform.skewY + _durationTransform.skewY * this._tweenProgress;
					}
				}
				
				if (_tweenScale)
				{
					if (_tweenScale == TWEEN_TYPE_ONCE)
					{
						_tweenScale = TWEEN_TYPE_NONE;
					}
					
					if (this._animationState.additiveBlending) // Additive blending
					{
						_transform.scaleX = _currentTransform.scaleX + _durationTransform.scaleX * this._tweenProgress;
						_transform.scaleY = _currentTransform.scaleY + _durationTransform.scaleY * this._tweenProgress;
					}
					else // Normal blending
					{
						_transform.scaleX = _originTransform.scaleX * (_currentTransform.scaleX + _durationTransform.scaleX * this._tweenProgress);
						_transform.scaleY = _originTransform.scaleY * (_currentTransform.scaleY + _durationTransform.scaleY * this._tweenProgress);
					}
				}
				
				bone.invalidUpdate();
			}
		}
		
		override public function fadeOut():void
		{
			_transform.skewX = Transform.normalizeRadian(_transform.skewX);
			_transform.skewY = Transform.normalizeRadian(_transform.skewY);
		}
		
		override public function update(time:int):void	
		{
			super.update(time);
			
			// Blend animation state
			const weight:Number = this._animationState._weightResult;
			
			if (weight > 0)
			{
				if (this._animationState._index <= 1)
				{
					_boneTransform.x = _transform.x * weight;
					_boneTransform.y = _transform.y * weight;
					_boneTransform.skewX = _transform.skewX * weight;
					_boneTransform.skewY = _transform.skewY * weight;
					_boneTransform.scaleX = (_transform.scaleX - 1) * weight + 1;
					_boneTransform.scaleY = (_transform.scaleY - 1) * weight + 1;
				}
				else
				{
					_boneTransform.x += _transform.x * weight;
					_boneTransform.y += _transform.y * weight;
					_boneTransform.skewX += _transform.skewX * weight;
					_boneTransform.skewY += _transform.skewY * weight;
					_boneTransform.scaleX += (_transform.scaleX - 1) * weight;
					_boneTransform.scaleY += (_transform.scaleY - 1) * weight;
				}
				
				const fadeProgress:Number = this._animationState._fadeProgress;
				if (fadeProgress < 1)
				{
					bone.invalidUpdate();
				}
			}
		}
	}
}