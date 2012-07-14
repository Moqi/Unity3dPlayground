package global {
	
	import cil2as.ByRef;
	import System._Math;
	import System.CLIArrayFactory;
	import System.IDisposable;
	import System.StringOperations;
	import System.Type;
	import System.Collections.DictionaryEntry;
	import System.Collections.Hashtable;
	import System.Collections.IDictionaryEnumerator;
	import UnityEngine._Object;
	import UnityEngine.Camera;
	import UnityEngine.CameraClearFlags;
	import UnityEngine.GameObject;
	import UnityEngine.GL;
	import UnityEngine.HideFlags;
	import UnityEngine.LayerMask;
	import UnityEngine.Material;
	import UnityEngine.Matrix4x4;
	import UnityEngine.MonoBehaviour;
	import UnityEngine.QualitySettings;
	import UnityEngine.Quaternion;
	import UnityEngine.RenderTexture;
	import UnityEngine.Shader;
	import UnityEngine.Skybox;
	import UnityEngine.SystemInfo;
	import UnityEngine.Time;
	import UnityEngine.Vector3;
	import UnityEngine.Vector4;
	import UnityEngine.Serialization.IDeserializable;
	import UnityEngine.Serialization.PPtrRemapper;
	import UnityEngine.Serialization.SerializedStateReader;
	import UnityEngine.Serialization.SerializedStateWriter;
	
	public class Water extends MonoBehaviour implements IDeserializable {
		
		public var Water$m_WaterMode$: Water_WaterMode = Water_WaterMode.Refractive;
		
		public var Water$m_DisablePixelLights$: Boolean = true;
		
		public var Water$m_TextureSize$: int = 256;
		
		public var Water$m_ClipPlaneOffset$: Number = 0.07;
		
		public var Water$m_ReflectLayers$: LayerMask = LayerMask.op_Implicit_Int32_LayerMask(-1);
		
		public var Water$m_RefractLayers$: LayerMask = LayerMask.op_Implicit_Int32_LayerMask(-1);
		
		public var Water$m_ReflectionCameras$: Hashtable = new Hashtable().Hashtable_Constructor();
		
		public var Water$m_RefractionCameras$: Hashtable = new Hashtable().Hashtable_Constructor();
		
		public var Water$m_ReflectionTexture$: RenderTexture;
		
		public var Water$m_RefractionTexture$: RenderTexture;
		
		public var Water$m_HardwareWaterSupport$: Water_WaterMode = Water_WaterMode.Refractive;
		
		public var Water$m_OldReflectionTextureSize$: int;
		
		public var Water$m_OldRefractionTextureSize$: int;
		
		public static var Water$s_InsideWater$: Boolean;
		
		public function Water_OnWillRenderObject(): void {
			if ((((!super.Behaviour_enabled) || (!_Object.Object_op_Implicit_Object_Boolean(super.Component_renderer))) || (!_Object.Object_op_Implicit_Object_Boolean(super.Component_renderer.Renderer_sharedMaterial))) || (!super.Component_renderer.Renderer_enabled)) {
				return;
			}
			var $current: Camera = Camera.current;
			if (!_Object.Object_op_Implicit_Object_Boolean($current)) {
				return;
			}
			if (Water$s_InsideWater$) {
				return;
			}
			Water$s_InsideWater$ = true;
			this.Water$m_HardwareWaterSupport$ = this.Water_FindHardwareWaterSupport();
			var $waterMode: Water_WaterMode = this.Water_GetWaterMode();
			var $camera: Camera;
			var $camera2: Camera;
			this.Water_CreateWaterObjects_Camera_CameraRef_CameraRef($current, new ByRef((function(): Camera {
				return $camera;
			}
			), (function($value$: Camera): void {
				$camera = $value$;
			}
			)), new ByRef((function(): Camera {
				return $camera2;
			}
			), (function($value$: Camera): void {
				$camera2 = $value$;
			}
			)));
			var $position: Vector3 = super.Component_transform.position.cil2as::Copy();
			var $up: Vector3 = super.Component_transform.up.cil2as::Copy();
			var $pixelLightCount: int = QualitySettings.pixelLightCount;
			if (this.Water$m_DisablePixelLights$) {
				QualitySettings.pixelLightCount = 0;
			}
			this.Water_UpdateCameraModes_Camera_Camera($current, $camera);
			this.Water_UpdateCameraModes_Camera_Camera($current, $camera2);
			if ($waterMode.value >= Water_WaterMode.Reflective.value) {
				var $w: Number = (-Vector3.Dot_Vector3_Vector3($up, $position)) - this.Water$m_ClipPlaneOffset$;
				var $plane: Vector4 = new Vector4().Constructor_Single_Single_Single_Single($up.x, $up.y, $up.z, $w);
				var $zero: Matrix4x4 = Matrix4x4.zero.cil2as::Copy();
				Water_CalculateReflectionMatrix_Matrix4x4Ref_Vector4($zero, $plane);
				var $position2: Vector3 = $current.Component_transform.position.cil2as::Copy();
				var $position3: Vector3 = $zero.MultiplyPoint_Vector3($position2);
				$camera.worldToCameraMatrix = Matrix4x4.op_Multiply_Matrix4x4_Matrix4x4($current.worldToCameraMatrix, $zero);
				var $clipPlane: Vector4 = this.Water_CameraSpacePlane_Camera_Vector3_Vector3_Single($camera, $position, $up, 1);
				var $projectionMatrix: Matrix4x4 = $current.projectionMatrix.cil2as::Copy();
				Water_CalculateObliqueMatrix_Matrix4x4Ref_Vector4($projectionMatrix, $clipPlane);
				$camera.projectionMatrix = $projectionMatrix.cil2as::Copy();
				$camera.cullingMask = -17 & this.Water$m_ReflectLayers$.value;
				$camera.targetTexture = this.Water$m_ReflectionTexture$;
				GL.GL_SetRevertBackfacing_Boolean(true);
				$camera.Component_transform.position = $position3.cil2as::Copy();
				var $eulerAngles: Vector3 = $current.Component_transform.eulerAngles.cil2as::Copy();
				$camera.Component_transform.eulerAngles = new Vector3().Constructor_Single_Single_Single(-$eulerAngles.x, $eulerAngles.y, $eulerAngles.z);
				$camera.Camera_Render();
				$camera.Component_transform.position = $position2.cil2as::Copy();
				GL.GL_SetRevertBackfacing_Boolean(false);
				super.Component_renderer.Renderer_sharedMaterial.Material_SetTexture_String_Texture("_ReflectionTex", this.Water$m_ReflectionTexture$);
			}
			if ($waterMode.value >= Water_WaterMode.Refractive.value) {
				$camera2.worldToCameraMatrix = $current.worldToCameraMatrix.cil2as::Copy();
				var $clipPlane2: Vector4 = this.Water_CameraSpacePlane_Camera_Vector3_Vector3_Single($camera2, $position, $up, -1);
				var $projectionMatrix2: Matrix4x4 = $current.projectionMatrix.cil2as::Copy();
				Water_CalculateObliqueMatrix_Matrix4x4Ref_Vector4($projectionMatrix2, $clipPlane2);
				$camera2.projectionMatrix = $projectionMatrix2.cil2as::Copy();
				$camera2.cullingMask = -17 & this.Water$m_RefractLayers$.value;
				$camera2.targetTexture = this.Water$m_RefractionTexture$;
				$camera2.Component_transform.position = $current.Component_transform.position.cil2as::Copy();
				$camera2.Component_transform.rotation = $current.Component_transform.rotation.cil2as::Copy();
				$camera2.Camera_Render();
				super.Component_renderer.Renderer_sharedMaterial.Material_SetTexture_String_Texture("_RefractionTex", this.Water$m_RefractionTexture$);
			}
			if (this.Water$m_DisablePixelLights$) {
				QualitySettings.pixelLightCount = $pixelLightCount;
			}
			switch ($waterMode) {
				case Water_WaterMode.Simple:
					{
						Shader.Shader_EnableKeyword_String("WATER_SIMPLE");
						Shader.Shader_DisableKeyword_String("WATER_REFLECTIVE");
						Shader.Shader_DisableKeyword_String("WATER_REFRACTIVE");
						break;
					}
				case Water_WaterMode.Reflective:
					{
						Shader.Shader_DisableKeyword_String("WATER_SIMPLE");
						Shader.Shader_EnableKeyword_String("WATER_REFLECTIVE");
						Shader.Shader_DisableKeyword_String("WATER_REFRACTIVE");
						break;
					}
				case Water_WaterMode.Refractive:
					{
						Shader.Shader_DisableKeyword_String("WATER_SIMPLE");
						Shader.Shader_DisableKeyword_String("WATER_REFLECTIVE");
						Shader.Shader_EnableKeyword_String("WATER_REFRACTIVE");
						break;
					}
			}
			Water$s_InsideWater$ = false;
		}
		
		public function Water_OnDisable(): void {
			if (_Object.Object_op_Implicit_Object_Boolean(this.Water$m_ReflectionTexture$)) {
				_Object.Object_DestroyImmediate_Object(this.Water$m_ReflectionTexture$);
				this.Water$m_ReflectionTexture$ = null;
			}
			if (_Object.Object_op_Implicit_Object_Boolean(this.Water$m_RefractionTexture$)) {
				_Object.Object_DestroyImmediate_Object(this.Water$m_RefractionTexture$);
				this.Water$m_RefractionTexture$ = null;
			}
			var $enumerator: IDictionaryEnumerator = this.Water$m_ReflectionCameras$.IDictionary_GetEnumerator();
			try {
				while ($enumerator.IEnumerator_MoveNext()) {
					var $dictionaryEntry: DictionaryEntry = $enumerator.IEnumerator_Current as DictionaryEntry;
					_Object.Object_DestroyImmediate_Object(($dictionaryEntry.Value as Camera).Component_gameObject);
				}
			} finally {
				var $disposable: IDisposable = $enumerator as IDisposable;
				if ($disposable != null) {
					$disposable.IDisposable_Dispose();
				}
			}
			this.Water$m_ReflectionCameras$.IDictionary_Clear();
			var $enumerator2: IDictionaryEnumerator = this.Water$m_RefractionCameras$.IDictionary_GetEnumerator();
			try {
				while ($enumerator2.IEnumerator_MoveNext()) {
					var $dictionaryEntry2: DictionaryEntry = $enumerator2.IEnumerator_Current as DictionaryEntry;
					_Object.Object_DestroyImmediate_Object(($dictionaryEntry2.Value as Camera).Component_gameObject);
				}
			} finally {
				var $disposable2: IDisposable = $enumerator2 as IDisposable;
				if ($disposable2 != null) {
					$disposable2.IDisposable_Dispose();
				}
			}
			this.Water$m_RefractionCameras$.IDictionary_Clear();
		}
		
		public function Water_Update(): void {
			if (!_Object.Object_op_Implicit_Object_Boolean(super.Component_renderer)) {
				return;
			}
			var $sharedMaterial: Material = super.Component_renderer.Renderer_sharedMaterial;
			if (!_Object.Object_op_Implicit_Object_Boolean($sharedMaterial)) {
				return;
			}
			var $vector: Vector4 = $sharedMaterial.Material_GetVector_String("WaveSpeed");
			var $float: Number = $sharedMaterial.Material_GetFloat_String("_WaveScale");
			var $vector2: Vector4 = new Vector4().Constructor_Single_Single_Single_Single($float, $float, $float * 0.4, $float * 0.45);
			var $num: Number = Number(Time.timeSinceLevelLoad) / 20;
			var $vector3: Vector4 = new Vector4().Constructor_Single_Single_Single_Single(Number(_Math.IEEERemainder(Number($vector.x * $vector2.x) * $num, 1)), Number(_Math.IEEERemainder(Number($vector.y * $vector2.y) * $num, 1)), Number(_Math.IEEERemainder(Number($vector.z * $vector2.z) * $num, 1)), Number(_Math.IEEERemainder(Number($vector.w * $vector2.w) * $num, 1)));
			$sharedMaterial.Material_SetVector_String_Vector4("_WaveOffset", $vector3);
			$sharedMaterial.Material_SetVector_String_Vector4("_WaveScale4", $vector2);
			var $size: Vector3 = super.Component_renderer.Renderer_bounds.size.cil2as::Copy();
			var $s: Vector3 = new Vector3().Constructor_Single_Single_Single($size.x * $vector2.x, $size.z * $vector2.y, 1);
			var $matrix: Matrix4x4 = Matrix4x4.TRS_Vector3_Quaternion_Vector3(new Vector3().Constructor_Single_Single_Single($vector3.x, $vector3.y, 0), Quaternion.identity.cil2as::Copy(), $s.cil2as::Copy());
			$sharedMaterial.Material_SetMatrix_String_Matrix4x4("_WaveMatrix", $matrix.cil2as::Copy());
			$s = new Vector3().Constructor_Single_Single_Single($size.x * $vector2.z, $size.z * $vector2.w, 1);
			$matrix = Matrix4x4.TRS_Vector3_Quaternion_Vector3(new Vector3().Constructor_Single_Single_Single($vector3.z, $vector3.w, 0), Quaternion.identity.cil2as::Copy(), $s.cil2as::Copy());
			$sharedMaterial.Material_SetMatrix_String_Matrix4x4("_WaveMatrix2", $matrix.cil2as::Copy());
		}
		
		public function Water_UpdateCameraModes_Camera_Camera($src: Camera, $dest: Camera): void {
			if (_Object.Object_op_Equality_Object_Object($dest, null)) {
				return;
			}
			$dest.clearFlags = $src.clearFlags;
			$dest.backgroundColor = $src.backgroundColor.cil2as::Copy();
			if ($src.clearFlags == CameraClearFlags.Skybox) {
				var $skybox: Skybox = $src.Component_GetComponent_Type(Skybox.$Type) as Skybox;
				var $skybox2: Skybox = $dest.Component_GetComponent_Type(Skybox.$Type) as Skybox;
				if ((!_Object.Object_op_Implicit_Object_Boolean($skybox)) || (!_Object.Object_op_Implicit_Object_Boolean($skybox.material))) {
					$skybox2.Behaviour_enabled_Boolean = false;
				} else {
					$skybox2.Behaviour_enabled_Boolean = true;
					$skybox2.material = $skybox.material;
				}
			}
			$dest.farClipPlane = $src.farClipPlane;
			$dest.nearClipPlane = $src.nearClipPlane;
			$dest.orthographic = $src.orthographic;
			$dest.fieldOfView = $src.fieldOfView;
			$dest.aspect = $src.aspect;
			$dest.orthographicSize = $src.orthographicSize;
		}
		
		public function Water_CreateWaterObjects_Camera_CameraRef_CameraRef($currentCamera: Camera, $reflectionCamera: ByRef, $refractionCamera: ByRef): void {
			var $waterMode: Water_WaterMode = this.Water_GetWaterMode();
			$reflectionCamera.value = null;
			$refractionCamera.value = null;
			if ($waterMode.value >= Water_WaterMode.Reflective.value) {
				if ((!_Object.Object_op_Implicit_Object_Boolean(this.Water$m_ReflectionTexture$)) || (this.Water$m_OldReflectionTextureSize$ != this.Water$m_TextureSize$)) {
					if (_Object.Object_op_Implicit_Object_Boolean(this.Water$m_ReflectionTexture$)) {
						_Object.Object_DestroyImmediate_Object(this.Water$m_ReflectionTexture$);
					}
					this.Water$m_ReflectionTexture$ = new RenderTexture().RenderTexture_Constructor_Int32_Int32_Int32(this.Water$m_TextureSize$, this.Water$m_TextureSize$, 16);
					this.Water$m_ReflectionTexture$.Object_name_String = "__WaterReflection" + super.GetInstanceID();
					this.Water$m_ReflectionTexture$.isPowerOfTwo = true;
					this.Water$m_ReflectionTexture$.Object_hideFlags_HideFlags = HideFlags.DontSave;
					this.Water$m_OldReflectionTextureSize$ = this.Water$m_TextureSize$;
				}
				$reflectionCamera.value = this.Water$m_ReflectionCameras$.IDictionary_get_Item_Object($currentCamera) as Camera;
				if (!_Object.Object_op_Implicit_Object_Boolean($reflectionCamera.value as Camera)) {
					var $gameObject: GameObject = new GameObject().GameObject_Constructor_String_TypeArray(StringOperations.String_Concat_ObjectArray(CLIArrayFactory.NewArrayWithElements(Type.ForClass(Object), "Water Refl Camera id", super.GetInstanceID(), " for ", $currentCamera.GetInstanceID())), CLIArrayFactory.NewArrayWithElements(Type.$Type, Camera.$Type, Skybox.$Type));
					$reflectionCamera.value = $gameObject.camera;
					($reflectionCamera.value as Camera).Behaviour_enabled_Boolean = false;
					($reflectionCamera.value as Camera).Component_transform.position = super.Component_transform.position.cil2as::Copy();
					($reflectionCamera.value as Camera).Component_transform.rotation = super.Component_transform.rotation.cil2as::Copy();
					($reflectionCamera.value as Camera).Component_gameObject.GameObject_AddComponent_String("FlareLayer");
					$gameObject.Object_hideFlags_HideFlags = HideFlags.HideAndDontSave;
					this.Water$m_ReflectionCameras$.IDictionary_set_Item_Object_Object($currentCamera, $reflectionCamera.value as Camera);
				}
			}
			if ($waterMode.value >= Water_WaterMode.Refractive.value) {
				if ((!_Object.Object_op_Implicit_Object_Boolean(this.Water$m_RefractionTexture$)) || (this.Water$m_OldRefractionTextureSize$ != this.Water$m_TextureSize$)) {
					if (_Object.Object_op_Implicit_Object_Boolean(this.Water$m_RefractionTexture$)) {
						_Object.Object_DestroyImmediate_Object(this.Water$m_RefractionTexture$);
					}
					this.Water$m_RefractionTexture$ = new RenderTexture().RenderTexture_Constructor_Int32_Int32_Int32(this.Water$m_TextureSize$, this.Water$m_TextureSize$, 16);
					this.Water$m_RefractionTexture$.Object_name_String = "__WaterRefraction" + super.GetInstanceID();
					this.Water$m_RefractionTexture$.isPowerOfTwo = true;
					this.Water$m_RefractionTexture$.Object_hideFlags_HideFlags = HideFlags.DontSave;
					this.Water$m_OldRefractionTextureSize$ = this.Water$m_TextureSize$;
				}
				$refractionCamera.value = this.Water$m_RefractionCameras$.IDictionary_get_Item_Object($currentCamera) as Camera;
				if (!_Object.Object_op_Implicit_Object_Boolean($refractionCamera.value as Camera)) {
					var $gameObject2: GameObject = new GameObject().GameObject_Constructor_String_TypeArray(StringOperations.String_Concat_ObjectArray(CLIArrayFactory.NewArrayWithElements(Type.ForClass(Object), "Water Refr Camera id", super.GetInstanceID(), " for ", $currentCamera.GetInstanceID())), CLIArrayFactory.NewArrayWithElements(Type.$Type, Camera.$Type, Skybox.$Type));
					$refractionCamera.value = $gameObject2.camera;
					($refractionCamera.value as Camera).Behaviour_enabled_Boolean = false;
					($refractionCamera.value as Camera).Component_transform.position = super.Component_transform.position.cil2as::Copy();
					($refractionCamera.value as Camera).Component_transform.rotation = super.Component_transform.rotation.cil2as::Copy();
					($refractionCamera.value as Camera).Component_gameObject.GameObject_AddComponent_String("FlareLayer");
					$gameObject2.Object_hideFlags_HideFlags = HideFlags.HideAndDontSave;
					this.Water$m_RefractionCameras$.IDictionary_set_Item_Object_Object($currentCamera, $refractionCamera.value as Camera);
				}
			}
		}
		
		public function Water_GetWaterMode(): Water_WaterMode {
			if (this.Water$m_HardwareWaterSupport$.value < this.Water$m_WaterMode$.value) {
				return this.Water$m_HardwareWaterSupport$;
			}
			return this.Water$m_WaterMode$;
		}
		
		public function Water_FindHardwareWaterSupport(): Water_WaterMode {
			if ((!SystemInfo.supportsRenderTextures) || (!_Object.Object_op_Implicit_Object_Boolean(super.Component_renderer))) {
				return Water_WaterMode.Simple;
			}
			var $sharedMaterial: Material = super.Component_renderer.Renderer_sharedMaterial;
			if (!_Object.Object_op_Implicit_Object_Boolean($sharedMaterial)) {
				return Water_WaterMode.Simple;
			}
			var $tag: String = $sharedMaterial.Material_GetTag_String_Boolean("WATERMODE", false);
			if ($tag == "Refractive") {
				return Water_WaterMode.Refractive;
			}
			if ($tag == "Reflective") {
				return Water_WaterMode.Reflective;
			}
			return Water_WaterMode.Simple;
		}
		
		public static function Water_sgn_Single($a: Number): Number {
			if ($a > 0) {
				return 1;
			}
			if ($a < 0) {
				return -1;
			}
			return 0;
		}
		
		public function Water_CameraSpacePlane_Camera_Vector3_Vector3_Single($cam: Camera, $pos: Vector3, $normal: Vector3, $sideSign: Number): Vector4 {
			var $v: Vector3 = Vector3.op_Addition_Vector3_Vector3($pos, Vector3.op_Multiply_Vector3_Single($normal, this.Water$m_ClipPlaneOffset$));
			var $worldToCameraMatrix: Matrix4x4 = $cam.worldToCameraMatrix.cil2as::Copy();
			var $lhs: Vector3 = $worldToCameraMatrix.MultiplyPoint_Vector3($v);
			var $rhs: Vector3 = Vector3.op_Multiply_Vector3_Single($worldToCameraMatrix.MultiplyVector_Vector3($normal).normalized, $sideSign);
			return new Vector4().Constructor_Single_Single_Single_Single($rhs.x, $rhs.y, $rhs.z, -Vector3.Dot_Vector3_Vector3($lhs, $rhs));
		}
		
		public static function Water_CalculateObliqueMatrix_Matrix4x4Ref_Vector4($projection: Matrix4x4, $clipPlane: Vector4): void {
			var $b: Vector4 = Matrix4x4.op_Multiply_Matrix4x4_Vector4($projection.inverse, new Vector4().Constructor_Single_Single_Single_Single(Water_sgn_Single($clipPlane.x), Water_sgn_Single($clipPlane.y), 1, 1));
			var $vector: Vector4 = Vector4.op_Multiply_Vector4_Single($clipPlane, 2 / Vector4.Dot_Vector4_Vector4($clipPlane, $b));
			$projection.set_Item_Int32_Single(2, $vector.x - $projection.get_Item_Int32(3));
			$projection.set_Item_Int32_Single(6, $vector.y - $projection.get_Item_Int32(7));
			$projection.set_Item_Int32_Single(10, $vector.z - $projection.get_Item_Int32(11));
			$projection.set_Item_Int32_Single(14, $vector.w - $projection.get_Item_Int32(15));
		}
		
		public static function Water_CalculateReflectionMatrix_Matrix4x4Ref_Vector4($reflectionMat: Matrix4x4, $plane: Vector4): void {
			$reflectionMat.m00 = 1 - ((2 * $plane.get_Item_Int32(0)) * $plane.get_Item_Int32(0));
			$reflectionMat.m01 = (-2 * $plane.get_Item_Int32(0)) * $plane.get_Item_Int32(1);
			$reflectionMat.m02 = (-2 * $plane.get_Item_Int32(0)) * $plane.get_Item_Int32(2);
			$reflectionMat.m03 = (-2 * $plane.get_Item_Int32(3)) * $plane.get_Item_Int32(0);
			$reflectionMat.m10 = (-2 * $plane.get_Item_Int32(1)) * $plane.get_Item_Int32(0);
			$reflectionMat.m11 = 1 - ((2 * $plane.get_Item_Int32(1)) * $plane.get_Item_Int32(1));
			$reflectionMat.m12 = (-2 * $plane.get_Item_Int32(1)) * $plane.get_Item_Int32(2);
			$reflectionMat.m13 = (-2 * $plane.get_Item_Int32(3)) * $plane.get_Item_Int32(1);
			$reflectionMat.m20 = (-2 * $plane.get_Item_Int32(2)) * $plane.get_Item_Int32(0);
			$reflectionMat.m21 = (-2 * $plane.get_Item_Int32(2)) * $plane.get_Item_Int32(1);
			$reflectionMat.m22 = 1 - ((2 * $plane.get_Item_Int32(2)) * $plane.get_Item_Int32(2));
			$reflectionMat.m23 = (-2 * $plane.get_Item_Int32(3)) * $plane.get_Item_Int32(2);
			$reflectionMat.m30 = 0;
			$reflectionMat.m31 = 0;
			$reflectionMat.m32 = 0;
			$reflectionMat.m33 = 1;
		}
		
		cil2as static function DefaultValue(): Water {
			return new Water().Water_Constructor();
		}
		
		public function Deserialize(reader: SerializedStateReader): void {
			this.Water$m_WaterMode$ = Water_WaterMode.ValueOf(reader.ReadInt());
			this.Water$m_DisablePixelLights$ = reader.ReadBool();
			reader.Align();
			this.Water$m_TextureSize$ = reader.ReadInt();
			this.Water$m_ClipPlaneOffset$ = reader.ReadFloat();
			this.Water$m_ReflectLayers$ = LayerMask.cil2as::DefaultValue();
			reader.ReadIDeserializable(this.Water$m_ReflectLayers$);
			this.Water$m_RefractLayers$ = LayerMask.cil2as::DefaultValue();
			reader.ReadIDeserializable(this.Water$m_RefractLayers$);
		}
		
		public function Serialize(writer: SerializedStateWriter): void {
			writer.WriteInt(this.Water$m_WaterMode$.value);
			writer.WriteBool(this.Water$m_DisablePixelLights$);
			writer.Align();
			writer.WriteInt(this.Water$m_TextureSize$);
			writer.WriteFloat(this.Water$m_ClipPlaneOffset$);
			writer.WriteIDeserializable(this.Water$m_ReflectLayers$);
			writer.WriteIDeserializable(this.Water$m_RefractLayers$);
		}
		
		public function RemapPPtrs(remapper: PPtrRemapper): void {
		}
		
		public function Water_Constructor(): Water {
			this.MonoBehaviour_Constructor();
			return this;
		}
		
		public static function get $Type(): Type {
			return _$Type != null ? _$Type : (_$Type = new Type(global.Water, {"OnWillRenderObject" : "Water_OnWillRenderObject", "OnDisable" : "Water_OnDisable", "Update" : "Water_Update", "UpdateCameraModes" : "Water_UpdateCameraModes_Camera_Camera", "CreateWaterObjects" : "Water_CreateWaterObjects_Camera_CameraRef_CameraRef", "GetWaterMode" : "Water_GetWaterMode", "FindHardwareWaterSupport" : "Water_FindHardwareWaterSupport", "sgn" : "Water_sgn_Single", "CameraSpacePlane" : "Water_CameraSpacePlane_Camera_Vector3_Vector3_Single", "CalculateObliqueMatrix" : "Water_CalculateObliqueMatrix_Matrix4x4Ref_Vector4", "CalculateReflectionMatrix" : "Water_CalculateReflectionMatrix_Matrix4x4Ref_Vector4"}, MonoBehaviour.$Type));
		}
		
		public static var _$Type: Type;
	}
}
