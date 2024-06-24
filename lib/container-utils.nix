{ lib, ... }:

{
  # Given a attrset of images and a function which generates an image spec,
  # generates a set of containers (although this could in theory be used for
  # other things... I'd like to see people try)
  #
  # container set must be in the below format
  # { container-name = {image = "image-uri"; scale = n;}; }
  # where image-uri gets passed in to the container-spec function as a custom
  # parameter, and scale is an integer that generates the containers
  #
  # container-spec must be a function which accepts two parameter (the
  # container name and image name) and ideally returns an oci-compliant
  # container.
  #
  # args:
  # containers: an AttrSet which specifies the imageUri and scale of each
  #   container
  # container-spec: a function which produces an oci-compliant container spec
  #
  # type:
  # AttrSet -> (String -> AttrSet -> AttrSet) -> AttrSet
  createTemplatedContainers =
    containers: container-spec:
    builtins.listToAttrs (
      lib.flatten (
        lib.mapAttrsToList (
          name: value:
          (map (
            num:
            let
              container-name = "${name}-${toString num}";
            in
            {
              name = container-name;
              value = container-spec container-name value.image;
            }
          ) (lib.lists.range 1 value.scale))
        ) containers
      )
    );
}
