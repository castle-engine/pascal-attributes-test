# Test Pascal custom RTTI attributes

FPC (requires 3.3.1, does not work with 3.2.0):

* https://wiki.freepascal.org/FPC_New_Features_Trunk#Support_for_custom_attributes

* https://wiki.freepascal.org/Custom_Attributes

Delphi:

* https://docwiki.embarcadero.com/RADStudio/Sydney/en/Declaring_Custom_Attributes_(RTTI)

Tested with FPC from GitLab latest on 2022-12-06.

Some results:

* FPC has limitations: only published properties may have attributes (not methods, not unpublished properties).

    This precludes usage like this for methods:

    ```pascal
    // will not work in FPC -- neither in private nor published sections:

    [CastleTest]
    class procedure TestSomethingAutomatic;

    [CastleMenu('Reload URL')]
    procedure ReloadUrl;
    ```

    This precludes usage to do anything on public properties. Bah, we would not be able to access them anyway I guess since no RTTI, so this makes sense.

    ```pascal
    // will not work in FPC -- attributes are not allowed in non-published sections,
    // and we cannot declare TCastleColor in published section.

    [CastleSerializedVector]
    property Color: TCastleColor read FColor write FColor;
    ```

    So it's not a solution to being able to easily (de)serialize our vectors.

* It's not really useful to register components. At least I don't see how to make attribute CastleComponentAttribute handled automatically without additional per-class call (which makes using the attribute pointless).

    So this is possible... but a bit pointless (requires additional call to process `TMyFancyImage` attributes, which mean we could as well just call `RegisterSerializableComponent` explicitly).

    ```pascal
    [CastleComponent('My Fancy Image')]
    TMyFancyImage = class(TAnnotatedCastleUserInterface)
    ...
    end;
    ```

* It's useful only to replace `PropertySections` overrides. This works nicely (not implemented detection for now, but we could, in CGE editor).

    ```pascal
    [CastlePropertySections([])]
    property ...;

    [CastlePropertySections([psBasic])]
    property ...;

    [CastlePropertySections([psLayout])]
    property ...;

    [CastlePropertySections([psBasic, psLayout])]
    property ...;
    ```

* Requires FPC 3.3.1.
