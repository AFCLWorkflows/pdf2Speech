package function;

import lombok.*;

import java.util.List;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class SplitOutput {
    private List<String> files;
    private Integer filesCount;
}
