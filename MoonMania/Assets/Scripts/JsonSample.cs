using UnityEngine;
using System.Collections;

public class JsonSample : MonoBehaviour 
{
    private string url = "http://www.dognrapport.dk/api/1.0/district/1";
    private string _response = "";
	// Use this for initialization
	void Start () 
    {
        StartCoroutine(GetImage());
	}
	
	// Update is called once per frame
	void Update () 
    {
	
	}

    void OnGUI()
    {
        GUI.TextArea(new Rect(0f, 0f, 200f, 300f), _response);
    }

    
    IEnumerator GetImage()
    {
        WWW www = new WWW(url);
        yield return www;
        //renderer.material.mainTexture = www.text;
        Debug.Log("Result: " +www.text);
        _response = www.text;
        var json = new JSONObject(www.text);
        accessData(json);
    }

    void accessData(JSONObject obj)
    {
        switch (obj.type)
        {
            case JSONObject.Type.OBJECT:
                for (int i = 0; i < obj.list.Count; i++)
                {
                    string key = (string)obj.keys[i];
                    JSONObject j = (JSONObject)obj.list[i];
                    Debug.Log(key);
                    accessData(j);
                }
                break;
            case JSONObject.Type.ARRAY:
                foreach (JSONObject j in obj.list)
                {
                    accessData(j);
                }
                break;
            case JSONObject.Type.STRING:
                Debug.Log(obj.str);
                break;
            case JSONObject.Type.NUMBER:
                Debug.Log(obj.n);
                break;
            case JSONObject.Type.BOOL:
                Debug.Log(obj.b);
                break;
            case JSONObject.Type.NULL:
                Debug.Log("NULL");
                break;

        }
    }
}
